// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract FunctionOverloading {
    event Transfer(address indexed from, address indexed to, uint amount);
    event Transfer(address indexed from, address indexed to, uint amount, string memo);

    mapping(address => uint) public balanceOf;

    function transfer(address to, uint amount) public {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance.");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function transfer(address to, uint amount, string memory memo) public {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance.");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount, memo);
    }
}