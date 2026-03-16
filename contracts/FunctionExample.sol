// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract FunctionExample {
    uint public count;

    // no param, no returns
    function increment() public {
        count++;
    }

    // with a param
    function setCount(uint _value) public {
        count = _value;
    }

    // with returns
    function getCount() public view returns (uint) {
        return count;
    }

    // with params and returns
    function add(uint _v1, uint _v2) public pure returns (uint) {
        return _v1 + _v2;
    }

    // returns with param name
    function calculate(uint _v1, uint _v2) 
        public pure returns (uint sum, uint product) {
        sum = _v1 + _v2;
        product = _v1 * _v2;
    }

    function testCalculate() public pure returns (uint value) {
        // receive all returns
        (uint sum, uint product) = calculate(1, 2);

        // receive partial returns
        (uint sum2, ) = calculate(1, 2);

        value = sum + product + sum2;
    }

    // reference type param, needs to specify the storage location
    function getLength(uint[] memory arr) public pure returns (uint) {
        return arr.length;
    }

    // calldata is more gas-efficient than memory
    function getLength2(uint[] calldata arr) public pure returns (uint) {
        return arr.length;
    }
}