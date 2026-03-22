// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

library MathLib {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
}

contract MyContract {
    using MathLib for uint256;

    function test() public pure returns (uint256) {
        uint x = 10;

        return x.add(20); // x.add(20) is equivalent to MathLib.add(x, 20)
    }
}