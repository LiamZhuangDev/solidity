// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract PausableVault {
    address public owner;
    mapping(address => uint) public balanceOf;
    bool public paused = false;
    uint public constant MIN_AMOUNT = 0.01 ether;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier minValue(uint amount) {
        require(msg.value >= amount, "Amount too low");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "Contract is not paused");
        _;
    }

    function deposit() public payable minValue(MIN_AMOUNT) whenNotPaused {
        balanceOf[msg.sender] += msg.value;
    }

    function withdraw(uint amount) public whenNotPaused {
        require(balanceOf[msg.sender] >= amount, "insufficient balance");
        balanceOf[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "withdraw failed");
    }

    function checkBalance() public view returns (uint) {
        return balanceOf[msg.sender];
    }

    function checkContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    function pause() public onlyOwner whenNotPaused {
        paused = true;
    }

    function resume() public onlyOwner whenPaused {
        paused = false;
    }
}