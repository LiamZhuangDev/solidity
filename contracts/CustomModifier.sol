// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract CustomModifier {
    address public owner;
    mapping(address => uint) public balances;
    bool private locked = false;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier validAddress(address _addr) {
        require(_addr != address(0), "Invalid address");
        _;
    }

    modifier minAmount(uint _minAmount) {
        require(msg.value >= _minAmount, "Amount too low");
        _;
    }

    modifier noReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    function withdraw(uint amount) public onlyOwner noReentrant {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdraw failed");
    }

    function deposit() public payable minAmount(0.01 ether) {
        balances[msg.sender] += msg.value;
    }
}