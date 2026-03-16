// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract PayableExample {
    uint public totalReceived;
    mapping(address => uint) public balances;

    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        balances[msg.sender] += msg.value;
        totalReceived += msg.value;
    }

    function withdraw(uint amount) public {
        require(balances[msg.sender] > amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success);
    }

    receive() external payable { 
        balances[msg.sender] += msg.value;
    }

    fallback() external {
        // hanlde unknown functions, payable is optional
     }
}