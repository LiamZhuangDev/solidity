// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract Crowdfunding {
    enum State {
        Active, // fundraising in progress
        Success, // goal reached
        Failed, // deadline passed, goal not reached
        Withdrawn // funds claimed by owner
    }

    State public currState = State.Active;

    address public owner;
    uint public goal;
    uint public deadline;
    uint public totalFunded;

    mapping(address => uint) public fundsContributed;

    modifier inState(State expected) {
        require(currState == expected, "Invalid state");
        _;
    }

    constructor(uint _goal, uint _duration) {
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + _duration;
    }

    function contribute() external payable inState(State.Active) {
        require(block.timestamp < deadline, "Fundraising ended");
        require(msg.value > 0, "Must send ETH");

        fundsContributed[msg.sender] += msg.value;
        totalFunded += msg.value;
    }

    function checkGoal() public inState(State.Active) {
        require(block.timestamp >= deadline, "Fundraising not ended");
        if (totalFunded >= goal) {
            currState = State.Success;
        } else {
            currState = State.Failed;
        }
    }

    function withdraw() public inState(State.Success) {
        require(block.timestamp >= deadline, "Fundraising not ended");
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "withdraw failed");
    }

    // Checks-Effects-Interactions pattern
    function refund() public inState(State.Failed) {
        // checks
        require(block.timestamp >= deadline, "Fundraising not ended");
        uint amount = fundsContributed[msg.sender];
        require(amount > 0, "No funds to refund");

        // effects
        fundsContributed[msg.sender] = 0;

        // interactions
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "refund failed");
    }

    receive() external payable {
        revert("Cannot send ETH directly to contract, call contribute function instead.");
    }
}