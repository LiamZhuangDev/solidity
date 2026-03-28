// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract SafeBatchTransfer {
    mapping(address => uint) public balanceOf;
    uint public constant MAX_BATCH_SIZE = 50;

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
    }

    function batchTransfer(address[] calldata recipients, uint[] calldata amounts) external {
        require(recipients.length == amounts.length, "length mismatch");
        require(recipients.length <= MAX_BATCH_SIZE, "batch too large");
        uint totalAmount = 0;
        for (uint i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }

        require(balanceOf[msg.sender] >= totalAmount, "insufficient balance");
        balanceOf[msg.sender] -= totalAmount;
        
        for (uint i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "invalid address");
            require(amounts[i] > 0, "invalid amount");
            address to = recipients[i];
            uint amount = amounts[i];
            balanceOf[to] += amount;

            (bool success, ) = payable(to).call{value: amount}("");
            require(success, "transfer failed");
        }
    }
}