// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

library AdvancedMath {
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;

        uint256 z = (x + 1) / 2; // next guess (starts at roughly x/2)
        uint256 y = x; // current best guess (starts very large number)

        while (z < y) {
            y = z;
            z = (z + x / z) / 2; // zₙ₊₁ = (zₙ + x / zₙ) / 2
        }

        return y;
    }

    // Greatest Common Divisor of a and b:
    // a   b   a % b
    // 30  20  10
    // 20  10  0
    // 10  0   returns 10 when b == 0
    function gcd(uint256 a, uint256 b) internal pure returns (uint256) {
        while (b != 0) {
            uint256 temp = b;
            b = a % b;
            a = temp;
        }

        return a;
    }

    function power(uint256 base, uint256 exponent) internal pure returns (uint256) {
        if (exponent == 0) return 1;

        uint256 result = 1;
        uint256 currBase = base;

        while (exponent > 0) {
            if (exponent % 2 == 1) {
                result *= currBase;
            }
            currBase *= currBase; // currBase ^ 2
            exponent /= 2;
        }

        return result;
    }
}

contract UseAdvancedMath {
    using AdvancedMath for uint256;

    function testSqrt(uint x) external pure returns (uint256) {
        return x.sqrt();
    }

    function testGcd(uint x, uint y) external pure returns (uint256) {
        return x.gcd(y);
    }

    function testPower(uint base, uint exponent) external pure returns (uint256) {
        return base.power(exponent);
    }
}