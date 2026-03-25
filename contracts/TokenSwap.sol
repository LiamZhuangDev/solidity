// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract TokenSwap {
    event SwapSuccess(address indexed user, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
    event SwapFailed(address indexed user, string reason);
    event SwapFailedPanic(address indexed user, uint256 errorCode);
    event SwapFailedCustom(address indexed user, bytes errorData);

    error SwapFailedError(address addr);

    function swap(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut) public returns (bool) {
        // IERC20(tokenIn) - cast an address into IERC20 interface, treat this address as an ERC20 token contract
        try IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn) returns (bool success) {
            if (!success) {
                emit SwapFailed(msg.sender, "TransferFrom returns false");
                revert SwapFailedError(msg.sender);
            }

            try IERC20(tokenOut).transfer(msg.sender, amountOut) returns (bool transferSuccess) {
                if (!transferSuccess) {
                    emit SwapFailed(msg.sender, "Transfer returns false");
                    revert SwapFailedError(msg.sender);
                }

                emit SwapSuccess(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
                return true;
            } catch Error(string memory reason) {
                emit SwapFailed(msg.sender, reason);
                revert SwapFailedError(msg.sender);
            } catch Panic(uint errorCode) {
                emit SwapFailedPanic(msg.sender, errorCode);
                revert SwapFailedError(msg.sender);
            } catch (bytes memory errorData) {
                emit SwapFailedCustom(msg.sender, errorData);
                revert SwapFailedError(msg.sender);
            }
        } catch Error(string memory reason) {
            emit SwapFailed(msg.sender, reason);
            revert SwapFailedError(msg.sender);
        } catch Panic(uint errorCode) {
            emit SwapFailedPanic(msg.sender, errorCode);
            revert SwapFailedError(msg.sender);
        } catch (bytes memory errorData) {
            emit SwapFailedCustom(msg.sender, errorData);
            revert SwapFailedError(msg.sender);
        }
    }
}