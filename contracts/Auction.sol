// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract Auction {
    enum State {
        Created,
        Active,
        Ended
    }

    State public currentState;

    address public owner;
    uint256 public endTime;

    address public highestBidder;
    uint256 public highestBid;

    mapping(address => uint256) public bids; // bidder => bid

    constructor(uint256 _biddingTime) {
        owner = msg.sender;
        currentState = State.Created;
        endTime = block.timestamp + _biddingTime;
    }

    // ============================ MODIFIERS ===============================
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier inState(State expected) {
        require(expected == currentState, "Invalid state");
        _;
    }

    // ============================= State Transition ========================
    function startAuction() external onlyOwner inState(State.Created) {
        currentState = State.Active;
    }

    function endAuction() external onlyOwner inState(State.Active) {
        require(block.timestamp >= endTime, "Too early");
        currentState = State.Ended;
    }

    // ============================ CORE LOGIC ================================
    function bid() external payable inState(State.Active) {
        require(block.timestamp < endTime, "Auction ended");
        require(msg.value > highestBid, "Bid too low");

        // keep track of the previous highest bid, used for withdrawal by users themselves
        // pull over push pattern
        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
    }

    function withdraw() external inState(State.Ended) {
        uint256 amount = bids[msg.sender];
        require(amount > 0, "No funds");

        bids[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
    }

    function finalize() external inState(State.Ended) {
        require(msg.sender == owner, "Not owner");
        require(highestBid > 0, "No bids");

        (bool success, ) = payable(owner).call{value: highestBid}("");
        require(success, "Finalization failed");
    }
}