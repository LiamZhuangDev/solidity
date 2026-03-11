// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract MultiDimensionalArray {
    
    uint[][] public matrix; // Dynamic two-dimensional array

    uint[2][3] public fixedMatrix; // fixed-size array with 3 elements, where each element is an array of 2 uint256 values (3 rows and 2 columns)

    uint[][5] public dynamicMatrix; // fixed-size array (5) where each element is a dynamic uint256 array
    
    uint[3][] public triplets; // dynamic array of fixed-size arrays (3 uint256 values each)
}