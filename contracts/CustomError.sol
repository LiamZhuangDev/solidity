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

    event OperationFailed(string reason);
    event PanicCaught(uint256 errorCode);

    constructor() {
        ce = new CustomError();
    }

    function testTransfer(address to, uint256 amount) public {
        try ce.transfer(to, amount) {
            // success case
        } catch Error(string memory reason) {
            emit OperationFailed(reason);
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
        } catch Panic(uint errorCode) {
            // 捕获Panic错误
            // errorCode可能的值：
            // 0x01: assert失败
            // 0x11: 算术运算溢出/下溢
            // 0x12: 除以零或模零
            // 0x21: 枚举转换错误
            // 0x22: 访问存储字节数组错误
            // 0x31: 对空数组调用.pop()
            // 0x32: 数组越界
            // 0x41: 分配过多内存
            // 0x51: 调用零值internal function
            emit PanicCaught(errorCode);
        }
    }
}