// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract CustomError {
    error InsufficientBalance(uint requested, uint available);
    error InvalidAddress(address addr);
    error AmountTooLow(uint amount, uint min);
    error TransferFailed();

    mapping(address => uint) public balanceOf;
    uint public constant MIN_AMOUNT = 100;

    function transfer(address to, uint amount) public {
        if (to == address(0)) {
            revert InvalidAddress(to);
        }

        if (amount < MIN_AMOUNT) {
            revert AmountTooLow(amount, MIN_AMOUNT);
        }

        if (balanceOf[msg.sender] < amount) {
            revert InsufficientBalance(amount, balanceOf[msg.sender]);
        }

        uint sumBeforeTransfer = balanceOf[msg.sender] + balanceOf[to];

        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        (bool success, ) = payable(to).call{value: amount}("");
        if (!success) {
            revert TransferFailed();
        }

        assert(sumBeforeTransfer == balanceOf[msg.sender] + balanceOf[to]);
    }
}