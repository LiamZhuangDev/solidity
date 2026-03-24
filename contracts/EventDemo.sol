// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract EventDemo {
    event Transfer(address indexed from, address indexed to, uint256 amount);

    mapping(address => uint256) public balanceOf;

    constructor() {
        balanceOf[msg.sender] = 1000;
    }

    function transfer(address to, uint256 amount) public {
        require(to != address(0), "to cannot be empty address");
        require(amount > 0, "amount must be greater than 0");
        require(balanceOf[msg.sender] >= amount, "insufficient funds");

        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(msg.sender, to, amount);
    }
}