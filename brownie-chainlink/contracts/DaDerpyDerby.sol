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
        bool executed; //sent for execution
        uint score; //score after execution finished
    }

struct KeyFlag { 
    uint key; 
    bool deleted;
    }

struct queue { 
    mapping(uint => submission) data;
    KeyFlag[] keys;
    uint queue_ticket_no;
    uint next_task;
}

type Iterator is uint;

library queueManagement {
    function insert(submission storage self, uint key, bytes32 script_cid_1, bytes32 script_cid_2) internal returns (bool replaced) {
        uint key_index = self.data[key].key_index;
        self.queue_ticket_no = self.queue_ticket_no + 1;
        self.data[key].queue_index = self.queue_ticket_no;
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

    function contains(submission storage self, uint key) internal view returns (bool) {
        return self.data[key].key_index > 0;
    }

    function iterateStart(submission storage self) internal view returns (Iterator) {
        return iteratorSkipDeleted(self, 0);
    }

    function iterateValid(submission storage self, Iterator iterator) internal view returns (bool) {
        return Iterator.unwrap(iterator) < self.keys.length;
    }

    function iterateNext(submission storage self, Iterator iterator) internal view returns (Iterator) {
        return iteratorSkipDeleted(self, Iterator.unwrap(iterator) + 1);
    }
        
    function pull_next_ticket(submission storage self, uint key) internal view returns (uint key, uint value) {
        uint key_index = self.data[key].key_index;
        key = self.keys[key_index].key;
        value = self.data[key].value;
    }

    function iteratorSkipDeleted(submission storage self, uint key_index) private view returns (Iterator) {
        while (key_index < self.keys.length && self.keys[key_index].deleted)
            key_index++;
        return Iterator.wrap(key_index);
    }
}

contract DaDerpyDerby is ChainlinkClient, KeeperCompatibleInterface, ConfirmedOwner{
    using Chainlink for Chainlink.Request;

        //game data
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
        jobId_ints =    "f485e865867047e3a6b6eefde9b3a600";
        jobId_ipfs =    "";
        fee = 1 * 10 ** 17;
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
    function execute_submission(submission calldata _submission) private returns (bytes32 requestId){
        string calldata _action = "ipfs";
        return call_cl_ea_mqtt_relay(_action, _topic, _qos, 0, 1);
    }
    function grab_score(string calldata _action, string calldata _topic, int16 _qos) private returns (bytes32 requestId){
        string calldata _action = "subscribe";
        return call_cl_ea_mqtt_relay(_action, score_topic, 2, 0, 1);
    }
    function clear_score() private returns (bytes32 requestId){
        string calldata _action = "publish";
        return call_cl_ea_mqtt_relay(_action, score_topic, 2, 0, 1);
    }
    function call_cl_ea_mqtt_relay(string calldata _action, string calldata _topic, int16 _qos, int256 _payload, int16 _retain) private returns (bytes32 requestId)
    {
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

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
}
