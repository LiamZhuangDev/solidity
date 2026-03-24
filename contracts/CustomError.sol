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

    receive() external payable {}
}

contract CustomErrorCaller {
    CustomError private ce;

    constructor() {
        ce = new CustomError();
    }

    function testTransfer(address to, uint256 amount) public {
        try ce.transfer(to, amount) {
            // success case
        } catch (bytes memory reason) {
            bytes4 selector;

            // memory layout of reason:
            // [0x00 - 0x1f] → length (N)
            // [0x20 - ... ] → actual data (N bytes)
            if (reason.length >= 4) {
                assembly {
                    // skip the first 32 bytes and points to the start of actual data
                    // mload returns 32 bytes which extracts the error selector: [selector (4 bytes) | rest of data (28 bytes)]
                    selector := mload(add(reason, 32))
                }
            }

            if (selector == CustomError.InsufficientBalance.selector) {
                // handle InsufficientBalance error
            } else if (selector == CustomError.InvalidAddress.selector) {
                // handle InvalidAddress error
            } else if (selector == CustomError.AmountTooLow.selector) {
                // handle AmountTooLow error
            } else if (selector == CustomError.TransferFailed.selector) {
                // handle TransferFailed error
            } else {
                // unknown error
            }
        }
    }
}