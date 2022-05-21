// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

    //using the "Iterable Mappings" Solidity example
struct Submission {
    address payable player;
    uint key_index; //storage position in the queue array
    uint ticket_index; //position in the queue for execution
    bytes32[2] script_cid; //script IPFS CID broken into halves
    bool executed; //sent for execution
    uint score; //score after execution finished
}

struct Key_Flag { 
    uint key; 
    bool deleted;
}

struct Tickets {
    uint num_tickets;
    uint curr_ticket;
    uint curr_ticket_key;
}

enum States {READY, SUBMITTED, EXECUTED, COLLECTED}

struct Queue { 
    mapping(uint => Submission) data;
    Key_Flag[] keys;
    Tickets tickets;
    States state;
}

struct High_Score {
    uint reset_interval;
    uint score;
    address payable leader;
    //todo: add growing pool of tokens here to award leader after reset interval rolls over
}

type Iterator is uint;

library Queue_Management {
    function initiate(Queue storage self) internal {
        self.tickets.num_tickets = 0; //will increment to 1 after first Submission
        self.tickets.curr_ticket = 0; //first ticket submitted will be ticket 1
        self.state = States.READY;
    }

    function insert(Queue storage self, uint key, bytes32 script_cid_1, bytes32 script_cid_2) internal returns (bool replaced) {
        uint key_index = self.data[key].key_index;
        self.tickets.num_tickets ++;
        self.data[key].ticket_index = self.tickets.num_tickets;
        self.data[key].script_cid[0] = script_cid_1;
        self.data[key].script_cid[1] = script_cid_2;
        self.data[key].executed = false;
        if (key_index > 0){ //checks if key already existed, and was overwritten
            self.keys[key_index].deleted = false; //a deleted Submission overwritten should not be marked deleted
            return true;
        } else { //if key didn't exist, the queue array has grown
            key_index = self.keys.length;
            self.keys.push();
            self.data[key].key_index = key_index + 1;
            self.keys[key_index].key = key;
            return false;
        }
    }

    function remove(Queue storage self, uint key) internal returns (bool success) {
        uint key_index = self.data[key].key_index;
        if (key_index == 0)
            return false;
        delete self.data[key];
        self.keys[key_index - 1].deleted = true;
        return true;
    }

    function set_curr_ticket_key(Queue storage self) internal {
        for(
            Iterator key = iterate_start(self);
            iterate_valid(self, key);
            key = iterate_next(self, key)
        ){
            if(!self.data[Iterator.unwrap(key)].executed && self.tickets.curr_ticket == self.data[Iterator.unwrap(key)].ticket_index){
                self.tickets.curr_ticket_key = Iterator.unwrap(key);
            }
        }
    }

    function pull_ticket(Queue storage self) internal view returns (string memory) {
        return bytes32_array_to_string(self.data[self.tickets.curr_ticket_key].script_cid);
    }

    function update_state(Queue storage self) internal {
        if(self.state == States.READY){
            self.state = States.SUBMITTED;
        }else if(self.state == States.SUBMITTED){
            self.state = States.EXECUTED;
        }else if(self.state == States.EXECUTED){
            self.state = States.COLLECTED;
        }else if(self.state == States.COLLECTED){
            self.state = States.READY;
        }
    }

    function update_execution_status(Queue storage self, bool status) internal {
        self.data[self.tickets.curr_ticket].executed = status;
    }

    function update_score(Queue storage self, uint score) internal {
        self.data[self.tickets.curr_ticket].score = score;
    }

    function iterate_start(Queue storage self) internal view returns (Iterator) {
        return iterator_skip_deleted(self, 0);
    }

    function iterate_valid(Queue storage self, Iterator iterator) internal view returns (bool) {
        return Iterator.unwrap(iterator) < self.keys.length;
    }

    function iterate_next(Queue storage self, Iterator iterator) internal view returns (Iterator) {
        return iterator_skip_deleted(self, Iterator.unwrap(iterator) + 1);
    }

    function iterator_skip_deleted(Queue storage self, uint key_index) internal view returns (Iterator) {
        while (key_index < self.keys.length && self.keys[key_index].deleted)
            key_index++;
        return Iterator.wrap(key_index);
    }

    function bytes32_array_to_string(bytes32[2] memory data) internal returns (string memory) {
        bytes memory bytes_string = new bytes(data.length * 32);
        uint string_len;
        for (uint i = 0; i < data.length; i++) {
            for (uint j = 0; j < 32; j++) {
                bytes1 char = bytes(bytes32(uint(data[i]) * 2 ** (8 * j)));
                if (char != 0) {
                    [string_len] = char;
                    string_len += 1;
                }
            }
        }
        bytes memory bytes_string_trimmed = new bytes(string_len);
        for (uint i = 0; i < string_len; i++) {
            bytes_string_trimmed[i] = bytes_string[i];
        }
        return string(bytes_string_trimmed);
    }
}

contract DaDerpyDerby is ChainlinkClient, KeeperCompatibleInterface, ConfirmedOwner{
        //game data
    Queue game;
    using Queue_Management for Queue;
    High_Score public high_score;
    uint public last_time_stamp;
    string private score_topic = "/score";
    
        //node data
    using Chainlink for Chainlink.Request;
    address private oracle;
    bytes32 private job_id_pubsub_ints;
    bytes32 private job_id_ipfs;
    uint256 private fee;
    
    /**
     * Network: Kovan
     * Oracle: 0xEcA7eD4a7e36c137F01f5DAD098e684882c8cEF3
     * Job IDs: below
     * Fee: 0.1 LINK
     */
    constructor(uint score_reset_interval) ConfirmedOwner(msg.sender) {
        setPublicChainlinkToken();
        oracle = 0xEcA7eD4a7e36c137F01f5DAD098e684882c8cEF3;
        job_id_pubsub_ints = "f485e865867047e3a6b6eefde9b3a600";
        job_id_ipfs = "";
        fee = 0.1 * (10 ** 18);
        game.initiate();
        high_score.reset_interval = score_reset_interval;
        last_time_stamp = block.timestamp;
    }

    function checkUpkeep(bytes calldata checkData) external override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = (block.timestamp - last_time_stamp) > high_score.reset_interval;

        if(game.state == States.READY){
            upkeepNeeded = game.tickets.curr_ticket < game.tickets.num_tickets;
        //note: no checks for States.SUBMITTED, becuase Fulfillment() should enact the state change to States.EXECUTED
        //todo: utilize States.SUBMITTED to monitor for execution failures
        }else if(game.state== States.EXECUTED){
            upkeepNeeded = true;
        }else if(game.state == States.COLLECTED){
            upkeepNeeded = true;
        }
        performData = checkData; //unused. separated logic executed based on internal states
    }

    function performUpkeep(bytes calldata performData) external override {
        performData; //unused. see above

        if((block.timestamp - last_time_stamp) > high_score.reset_interval){
            last_time_stamp = block.timestamp;
            award_winner();
            //todo:
            //  - search for list of executed submissions, and delete them using game.remove(key)
            //  - generate list of deleted submissions for replacment when new entries are made
        }
        if(game.state == States.READY && game.tickets.curr_ticket < game.tickets.num_tickets){
            game.tickets.curr_ticket ++;
            game.set_curr_ticket_key();
            execute_submission();
        //note: see above for States.SUBMITTED notes
        }else if(game.state == States.EXECUTED){
            collect_score();
        }else if(game.state == States.COLLECTED){
            clear_score();
        }
    }

        // need function iterating to grab deleted Submissions and storing their indicies in an array
    function join_queue(bytes32 script_cid_1, bytes32 script_cid_2) public returns (uint ticket){

    }

    function estimated_wait(uint ticket) public returns (uint time_minutes){
        //todo: user can get an estimated time for when a ticket is expected to execute
    }
    
    /**
     * Chainlink requests to
            - send IPFS scripts to cl-ea-mqtt-relay for executing games (execute_sumbission)
            - subscribe on game score topics to pull score data (grab_score)
            - publish on game score topics for resetting score data between script executions (clear_score)
        on the MQTT broker(s) utilized by the Node's External Adapter managing the game's state.
     */
    function execute_submission() private returns (bytes32 requestId){
        string memory topic = "script";
        string memory payload = game.pull_ticket();
        game.update_state();
        return call_ipfs(topic, payload); //qos and retained flags ignored
    }
    function collect_score() private returns (bytes32 requestId){
        string memory action = "subscribe";
        return call_pubsub_ints(action, score_topic, 2, 0, 0); //payload and retained flag ignored
    }
    function clear_score() private returns (bytes32 requestId){
        string memory action = "publish";
        return call_pubsub_ints(action, score_topic, 2, 0, 1); //payload = 0, retained = 1(true)
    }
    function call_pubsub_ints(
        string memory _action, 
        string memory _topic, 
        int16 _qos, 
        int256 _payload, 
        int16 _retain
        ) private returns (bytes32 requestId){
            Chainlink.Request memory request = buildChainlinkRequest(job_id_pubsub_ints, address(this), this.fulfill_score.selector);
            
            // Set the params for the external adapter
            request.add("action", _action); //options: "publish", "subscribe"
            request.add("topic", _topic);
            request.addInt("qos", _qos);
            request.addInt("payload", _payload);
            request.addInt("retain", _retain);
            
            // Sends the request
            return sendChainlinkRequestTo(oracle, request, fee);
    }
    function call_ipfs( 
        string memory _topic, 
        string memory _payload
        ) private returns (bytes32 requestId){
            string memory action = "ipfs";
            
            Chainlink.Request memory request = buildChainlinkRequest(job_id_ipfs, address(this), this.fulfill_execution_request.selector);
            
            // Set the params for the external adapter
            request.add("action", action); //"ipfs"
            request.add("topic", _topic); //subtasks: "script"
            //request.addInt("qos", _qos); //unused
            request.add("payload", _payload); //IPFS CID
            //request.addInt("retain", _retain); //unused
            
            // Sends the request
            return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_execution_request(bytes32 _requestId, bool status) public recordChainlinkFulfillment(_requestId){
        //todo: error catching on non-executed statuses
        game.update_execution_status(status);
        game.update_state();
    }
    function fulfill_score(bytes32 _requestId, uint256 score) public recordChainlinkFulfillment(_requestId){
        //todo: error catching on fails to pubsub scores
        if(game.state == States.COLLECTED){
            game.update_score(score);
        }
        game.update_state();
    }

    function award_winner() private {
        //todo: award pool to winner before resetting current leader and current high score
        high_score.leader = payable(0);
        high_score.score = 0;
    }

    function withdraw_link() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
    }
}
