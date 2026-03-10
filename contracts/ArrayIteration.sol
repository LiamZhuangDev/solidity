// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract ArrayIteration {
    uint[] public numbers;

    function addNumbers(uint[] calldata nums) external {
        for (uint i = 0; i < nums.length; i++) {
            numbers.push(nums[i]);
        }
    }

    function numbersGreaterThan1(uint threshold)
        public view returns (uint[] memory) {
            uint count = 0;
            uint len = numbers.length;

            for (uint i = 0; i < len; i++) {
                if (numbers[i] > threshold) {
                    count++;
                }
            }

            uint[] memory result = new uint[](count);
            uint index = 0;
            for (uint i = 0; i < len; i++) {
                if (numbers[i] > threshold) {
                    result[index] = numbers[i];
                    index++;
                }
            }

            return result;
    }

    function numbersGreaterThan2(uint threshold)
        public view returns (uint[] memory, uint) {
            uint count = 0;
            uint len = numbers.length;
            uint[] memory result = new uint[](len);

            for (uint i = 0; i < len; i++) {
                if (numbers[i] > threshold) {
                    result[count] = numbers[i];
                    count++;
                }
            }

            return (result, count);
        }

    function numbersGreaterThan3(uint threshold)
        public view returns (uint[] memory) {
            uint count = 0;
            uint len = numbers.length;
            uint[] memory result = new uint[](len);

            for (uint i = 0; i < len; i++) {
                if (numbers[i] > threshold) {
                    result[count] = numbers[i];
                    count++;
                }
            }

            assembly {
                mstore(result, count)
            }

            return result;
        }
}