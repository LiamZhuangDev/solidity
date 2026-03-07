// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract ExpensiveContract {
    uint256[] public numbers;
    address public admin;
    uint256 public multiplier = 2;

    function batchProcess(
        uint256[] memory inputs
    ) external {
        require(msg.sender == admin);

        for (uint i = 0; i < inputs.length; i++) {
            uint256 result = inputs[i] * multiplier;
            numbers.push(result);
        }
    }

    function getSum() external view returns (uint256) {
        require(msg.sender == admin);

        uint256 sum = 0;
        for (uint i = 0; i < numbers.length; i++) {
            sum += numbers[i];
        }

        return sum;
    }
}