// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract TimeLockedVault {
    mapping(address => uint) public balanceOf;
    mapping(address => uint) public lockedUntil;

    function deposit(uint lockDuration) public payable {
        require(msg.value > 0, "Must deposit ETH");
        require(lockDuration >= 1 days && lockDuration <= 365 days, "Duration must be 1-365 days");

        balanceOf[msg.sender] += msg.value;
        uint newLockedUntil = block.timestamp + lockDuration;
        if (newLockedUntil > lockedUntil[msg.sender]) {
            lockedUntil[msg.sender] = newLockedUntil;
        }
    }

    function withdraw() public {
        require(balanceOf[msg.sender] > 0, "No funds to withdraw");
        require(block.timestamp >= lockedUntil[msg.sender], "Funds are still locked");

        balanceOf[msg.sender] = 0;
        lockedUntil[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: balanceOf[msg.sender]}("");
        require(success, "withdraw failed");
    }

    function timeRemaining() public view returns (uint) {
        if (block.timestamp >= lockedUntil[msg.sender]) {
            return 0;
        }

        return lockedUntil[msg.sender] - block.timestamp;
    }
}