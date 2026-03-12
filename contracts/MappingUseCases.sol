// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract MappingUseCases {
    // Use case 1: Efficient lookup for large datasets
    mapping(address => uint) public balances;
    // Use case 2: Tracking used values without iteration
    mapping(bytes32 => bool) public usedNonces;
    // Use case 3: Managing membership in a set with unknown size
    mapping(address => bool) public isWhitelisted;
    // Use case 4: Direct key to value ownership lookup
    mapping(uint => address) public tokenOwners;
}