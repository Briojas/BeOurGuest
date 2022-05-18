// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

    //using the "Iterable Mappings" Solidity example
struct submission {
        uint key_index; //storage position in the queue array
        uint queue_index; //position in the queue for execution
        bytes32[2] script_cid; //script IPFS CID broken into halves
        bytes32 executed_id; //sent for execution
        bytes32 collect_score_id;
        bytes32 clear_score_id;
        uint score; //score after execution finished
    }

struct KeyFlag { 
    uint key; 
    bool deleted;
    }

struct queue { 
    mapping(uint => submission) data;
    KeyFlag[] keys;
    uint tickets;
    uint next_ticket;
    uint active_key;
}

type Iterator is uint;

library queue_management {
    function initiate(submission storage self) internal {
        self.tickets = 0; //will increment to 1 after first submission
        self.next_ticket = 1; //starts at first ticket submitted
    }

    function insert(submission storage self, uint key, bytes32 script_cid_1, bytes32 script_cid_2) internal returns (bool replaced) {
        uint key_index = self.data[key].key_index;
        self.tickets ++;
        self.data[key].queue_index = self.tickets;
        self.data[key].script_cid[0] = script_cid_1;
        self.data[key].script_cid[1] = script_cid_2;
        self.data[key].executed = false;
        if (key_index > 0){ //checks if key already existed, and was overwritten
            self.keys[key_index].deleted = false; //a deleted submission overwritten should not be marked deleted
            return true;
        } else { //if key didn't exist, the queue array has grown
            key_index = self.keys.length;
            self.keys.push();
            self.data[key].key_index = key_index + 1;
            self.keys[key_index].key = key;
            return false;
        }
    }

    function remove(submission storage self, uint key) internal returns (bool success) {
        uint key_index = self.data[key].key_index;
        if (key_index == 0)
            return false;
        delete self.data[key];
        self.keys[key_index - 1].deleted = true;
        return true;
    }

    function find_next_ticket(submission storage self) internal view returns (uint key) {
        for(
            Iterator key = iterate_start(self);
            iterate_valid(self, key);
            key = iterate_next(self, key)
        ){
            if(!self.data[key].executed && self.next_ticket == self.data[key].queue_index){
                return Iterator.unwrap(key);
            }
        }
    }

    function assign_active_key(submission storage self, uint key) internal {
        //note: assing active_key to current submission being processed
    }

    function pull_ticket(submission storage self, uint key) internal view returns (string cid) {
        self.data[key].executed = true;
        cid = bytes32_array_to_string(self.data[key].script_cid);
    }

    function iterate_start(submission storage self) internal view returns (Iterator) {
        return iterator_skip_deleted(self, 0);
    }

    function iterate_valid(submission storage self, Iterator iterator) internal view returns (bool) {
        return Iterator.unwrap(iterator) < self.keys.length;
    }

    function iterate_next(submission storage self, Iterator iterator) internal view returns (Iterator) {
        return iterator_skip_deleted(self, Iterator.unwrap(iterator) + 1);
    }

    function iterator_skip_deleted(submission storage self, uint key_index) private view returns (Iterator) {
        while (key_index < self.keys.length && self.keys[key_index].deleted)
            key_index++;
        return Iterator.wrap(key_index);
    }
}

contract DaDerpyDerby is ChainlinkClient, KeeperCompatibleInterface, ConfirmedOwner{
    using Chainlink for Chainlink.Request;

        //game data
    queue game;
    using queue_management for queue;
    uint256 public daily_high_score;
    string private score_topic = "/score";
    
        //node data
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
    constructor() ConfirmedOwner(msg.sender) {
        setPublicChainlinkToken();
        oracle = 0xEcA7eD4a7e36c137F01f5DAD098e684882c8cEF3;
        jobId_ints = "f485e865867047e3a6b6eefde9b3a600";
        jobId_ipfs = "";
        fee = 0.1 * (10 ** 18);
        game.initiate();
    }

    //note: drop queue functions here
        // need function iterating to grab deleted submissions and storing their indicies in an array
    function join_queue() public {

    }
    
    /**
     * Chainlink requests to
            - send IPFS scripts to cl-ea-mqtt-relay for executing games (execute_sumbission)
            - subscribe on game score topics to pull score data (grab_score)
            - publish on game score topics for resetting score data between script executions (clear_score)
        on the MQTT broker(s) utilized by the Node's External Adapter managing the game's state.
     */
    function execute_submission() private {
        string memory _action = "ipfs";
        string memory _topic = "script";
        string memory _payload = game.pull_ticket(key);
        game.data[game.active_key].executed_id = call_cl_ea_mqtt_relay(_action, _topic, 0, _payload, 0); //qos and retained flags ignored
    }
    function collect_score() private returns (bytes32 requestId){
        string calldata _action = "subscribe";
        game.data[game.active_key].collect_score_id = call_cl_ea_mqtt_relay(_action, score_topic, 2, 0, 0); //payload and retained flag ignored
    }
    function clear_score() private returns (bytes32 requestId){
        string calldata _action = "publish";
        game.data[game.active_key].clear_score_id = call_cl_ea_mqtt_relay(_action, score_topic, 2, 0, 1); //payload = 0
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
    function fulfill_int(bytes32 _requestId, uint256 returnInt) public recordChainlinkFulfillment(_requestId){
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
                bytes1 char = byte(bytes32(uint(data[i]) * 2 ** (8 * j)));
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
