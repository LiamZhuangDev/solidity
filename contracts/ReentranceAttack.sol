// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract Vulnerable {
    mapping(address => uint) balanceOf;

    function withdraw() public {
        uint amount = balanceOf[msg.sender];
        require(amount > 0, "insufficient balance");
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "withdraw failed");
        balanceOf[msg.sender] = 0;
    }
}

contract Attacker {
    Vulnerable public victim;

    receive() external payable {
        if (address(victim).balance > 0) {
            victim.withdraw();
        }
     }
}

contract Safe {
    mapping(address => uint) balanceOf;

    function withdraw() public {
        // checks
        uint amount = balanceOf[msg.sender];
        require(amount > 0, "insufficient balance");
        // effects
        balanceOf[msg.sender] = 0;
        // interactions
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "withdraw failed");
    }
}