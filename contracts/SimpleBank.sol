// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract SimpleBank {
    error InsufficientBalance(address addr, uint256 available, uint256 required);
    error InvalidAmount(uint256 amount);
    error WithdrawFailed();

    mapping(address => uint256) public balanceOf;

    event Deposit(address indexed addr, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);

    function deposit() public payable {
        require(msg.value > 0, "amount must be greater than 0");

        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public {
        if (amount == 0) {
            revert InvalidAmount(amount);
        }

        if (balanceOf[msg.sender] < amount) {
            revert InsufficientBalance(msg.sender, balanceOf[msg.sender], amount);
        }

        balanceOf[msg.sender] -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            // balanceOf[msg.sender] += amount; this is redundant as all state changes are automatically rolled back.
            revert WithdrawFailed();
        } else {
            emit Withdraw(msg.sender, amount);
        }
    }

    function getBalance() public view returns (uint256) {
        return balanceOf[msg.sender];
    }
}