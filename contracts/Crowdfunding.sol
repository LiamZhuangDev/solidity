// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract Crowdfunding {
    enum State {
        Active, // fundraising in progress
        Success, // goal reached
        Failed, // deadline passed, goal not reached
        Withdrawn // funds claimed by owner
    }

    error FundraisingStillActive();
    error FundraisingEnded();
    error InvalidAmount(uint256 amount);
    error Unauthorized(address addr);
    error RefundFailed(address addr);
    error WithdrawFailed(address addr);
    
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
        require(_goal > 0, "The goal must be greater than 0");
        require(_duration > 0, "The duration must be longer than 0");

        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + _duration;
    }

    function contribute() external payable inState(State.Active) {
        if (block.timestamp >= deadline) {
            revert FundraisingEnded();
        }
        if (msg.value == 0) {
            revert InvalidAmount(msg.value);
        }
        // require(block.timestamp < deadline, "Fundraising ended");
        // require(msg.value > 0, "Must send ETH");

        fundsContributed[msg.sender] += msg.value;
        totalFunded += msg.value;
    }

    function checkGoal() public inState(State.Active) {
        if (block.timestamp >= deadline) {
            revert FundraisingEnded();
        }
        // require(block.timestamp >= deadline, "Fundraising not ended");
        if (totalFunded >= goal) {
            currState = State.Success;
        } else {
            currState = State.Failed;
        }
    }

    function withdraw() public inState(State.Success) {
        // require(block.timestamp >= deadline, "Fundraising not ended");
        if (block.timestamp < deadline) {
            revert FundraisingStillActive();
        }
        if (msg.sender != owner) {
            revert Unauthorized(msg.sender);
        }
        
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        // require(success, "withdraw failed");
        if (!success) {
            revert WithdrawFailed(owner);
        }
    }

    // Checks-Effects-Interactions pattern
    function refund() public inState(State.Failed) {
        // checks
        // require(block.timestamp >= deadline, "Fundraising not ended");
        if (block.timestamp < deadline) {
            revert FundraisingEnded();
        }
        uint amount = fundsContributed[msg.sender];
        require(amount > 0, "No funds to refund");

        // effects
        fundsContributed[msg.sender] = 0;

        // interactions
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        // require(success, "refund failed");
        if (!success) {
            revert RefundFailed(msg.sender);
        }
    }

    function getProgress() public view returns (uint percentage) {
        return (totalFunded * 100) / goal;
    }

    receive() external payable {
        revert("Cannot send ETH directly to contract, call contribute function instead.");
    }
}