// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

    //using the "Iterable Mappings" Solidity example
struct Submission {
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

enum States {READY, SUBMITTING, COLLECTING, RESETTING}

struct Queue { 
    mapping(uint => Submission) data;
    Key_Flag[] keys;
    Tickets tickets;
    States state;
}

type Iterator is uint;

struct High_Score {
    uint immutable reset_interval;
    uint score;
    address leader;
}

library Queue_Management {
    function initiate(Submission storage self) internal {
        self.tickets.num_tickets = 0; //will increment to 1 after first Submission
        self.curr_ticket = 1; //starts at first ticket submitted
        self.state = States.READY;
    }

    function insert(Submission storage self, uint key, bytes32 script_cid_1, bytes32 script_cid_2) internal returns (bool replaced) {
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

    function remove(Submission storage self, uint key) internal returns (bool success) {
        uint key_index = self.data[key].key_index;
        if (key_index == 0)
            return false;
        delete self.data[key];
        self.keys[key_index - 1].deleted = true;
        return true;
    }

    function get_curr_ticket_key(Submission storage self) internal view returns (uint key) {
        for(
            Iterator key = iterate_start(self);
            iterate_valid(self, key);
            key = iterate_next(self, key)
        ){
            if(!self.data[key].executed && self.tickets.curr_ticket == self.data[key].ticket_index){
                return Iterator.unwrap(key);
            }
        }
    }

    function assign_curr_ticket_key(Submission storage self, uint key) internal {
        //note: assing active_key to current Submission being processed
    }

    function pull_ticket(Submission storage self, uint key) internal view returns (string) {
        return bytes32_array_to_string(self.data[key].script_cid);
    }

    function iterate_start(Submission storage self) internal view returns (Iterator) {
        return iterator_skip_deleted(self, 0);
    }

    function iterate_valid(Submission storage self, Iterator iterator) internal view returns (bool) {
        return Iterator.unwrap(iterator) < self.keys.length;
    }

    function iterate_next(Submission storage self, Iterator iterator) internal view returns (Iterator) {
        return iterator_skip_deleted(self, Iterator.unwrap(iterator) + 1);
    }

    function iterator_skip_deleted(Submission storage self, uint key_index) private view returns (Iterator) {
        while (key_index < self.keys.length && self.keys[key_index].deleted)
            key_index++;
        return Iterator.wrap(key_index);
    }
}

contract DaDerpyDerby is ChainlinkClient, KeeperCompatibleInterface, ConfirmedOwner{
        //game data
    Queue game;
    using Queue_Management for Queue;
    High_Score public high_score;
    string private score_topic = "/score";
    
        //node data
    using Chainlink for Chainlink.Request;
    address private oracle;
    bytes32 private jobId_ints;
    bytes32 private jobId_ipfs;
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
        jobId_ints = "f485e865867047e3a6b6eefde9b3a600";
        jobId_ipfs = "";
        fee = 0.1 * (10 ** 18);
        game.initiate();
        high_score.reset_interval = score_reset_interval;
    }

    function checkUpkeep(bytes calldata checkData) external override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;

        // We don't use the checkData in this example
        // checkData was defined when the Upkeep was registered
        performData = checkData;
    }

    function performUpkeep(bytes calldata performData) external override {
        lastTimeStamp = block.timestamp;
        counter = counter + 1;

        // We don't use the performData in this example
        // performData is generated by the Keeper's call to your `checkUpkeep` function
        performData;
        
    }

    //note: drop queue functions here
        // need function iterating to grab deleted Submissions and storing their indicies in an array
    function join_queue() public {

    }
    
    /**
     * Chainlink requests to
            - send IPFS scripts to cl-ea-mqtt-relay for executing games (execute_sumbission)
            - subscribe on game score topics to pull score data (grab_score)
            - publish on game score topics for resetting score data between script executions (clear_score)
        on the MQTT broker(s) utilized by the Node's External Adapter managing the game's state.
     */
    function execute_Submission() private {
        string memory action = "ipfs";
        string memory topic = "script";
        string memory payload = game.pull_ticket(key);
        call_cl_ea_mqtt_relay(action, topic, 0, payload, 0); //qos and retained flags ignored
    }
    function collect_score() private returns (bytes32 requestId){
        string calldata action = "subscribe";
        call_cl_ea_mqtt_relay(action, score_topic, 2, 0, 0); //payload and retained flag ignored
    }
    function clear_score() private returns (bytes32 requestId){
        string calldata action = "publish";
        call_cl_ea_mqtt_relay(action, score_topic, 2, 0, 1); //payload = 0
    }
    function call_cl_ea_mqtt_relay(string calldata _action, string calldata _topic, int16 _qos, int256 _payload, int16 _retain) private returns (bytes32 requestId){
        Chainlink.Request memory request = buildChainlinkRequest(jobId_ints, address(this), this.fulfill_int.selector);
        
        // Set the params for the external adapter
        request.add("action", _action); //options: "publish", "subscribe", "ipfs"
        request.add("topic", _topic);
        request.addInt("qos", _qos);
        request.addInt("payload", _payload);
        request.addInt("retain", _retain);
        
        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_execution_request(bytes32 _requestId, uint256 returnInt) public recordChainlinkFulfillment(_requestId){
        
        data_int = returnInt;
    }
    function fulfill_score(bytes32 _requestId, uint256 returnInt) public recordChainlinkFulfillment(_requestId){
        data_int = returnInt;
    }
    function get_int() public view returns (uint256){
        return data_int;
    }

    function withdraw_link() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
    }

    function bytes32_array_to_string(bytes32[] data) returns (string) {
        bytes memory bytes_string = new bytes(data.length * 32);
        uint string_len;
        for (uint i=0; i<data.length; i++) {
            for (uint j=0; j<32; j++) {
                bytes1 char = bytes(bytes32(uint(data[i]) * 2 ** (8 * j)));
                if (char != 0) {
                    [string_len] = char;
                    string_len += 1;
                }
            }
        }
        bytes memory bytes_string_trimmed = new bytes(string_len);
        for (i=0; i<string_len; i++) {
            bytes_string_trimmed[i] = bytes_string[i];
        }
        return string(bytes_string_trimmed);
    }    
}
