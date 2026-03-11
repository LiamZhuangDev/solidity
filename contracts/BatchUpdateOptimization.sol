// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract BatchUpdateOptimization {
    uint[] public data;

    function addData(uint[] calldata inputs) external {
        for (uint i = 0; i < inputs.length; i++) {
            data.push(inputs[i]);
        }
    }

    function updateAllBad(uint[] calldata newData) external {
        require(newData.length == data.length);
        uint len = data.length;

        for (uint i = 0; i < len; i++) {
            data[i] = newData[i]; // expensive when updating the array on storage in a loop
        }
    }

    function updateAllGood(uint[] calldata newData) external {
        require(newData.length == data.length);
        uint len = data.length;

        uint[] memory temp = new uint[](len);
        for (uint i = 0; i < len;) {
            temp[i] = newData[i];
            unchecked { i++; }
        }

        data = temp; // single storage update
    }
}