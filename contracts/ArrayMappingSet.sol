// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract ArrayMappingSet {
    address[] public users; // enumerable
    mapping(address => bool) public userRegistered; // efficient lookup
    mapping(address => uint) public userIndex; // keep track of each user in the array, used in a quick remove  
    uint public constant MAX_NUM_OF_USERS = 1000;

    function getAllUsers() public view returns (address[] memory) {
        return users;
    }

    function getUserCount() public view returns (uint) {
        return users.length;
    }

    function isUserRegistered(address user) public view returns (bool) {
        return userRegistered[user];
    }

    function addUser(address user) public {
        require(!userRegistered[user], "User already registed");
        require(users.length < MAX_NUM_OF_USERS, "Users exceeds max limit");
        users.push(user);
        userRegistered[user] = true;
        userIndex[user] = users.length - 1;
    }

    function removeUser(address user) public {
        require(userRegistered[user], "User not registered");

        uint index = userIndex[user];
        uint last = users.length - 1;
        if (index != last) {
            address lastUser = users[last];
            users[index] = lastUser;
            userIndex[lastUser] = index;
        }

        users.pop();
        delete userRegistered[user];
        delete userIndex[user];
    }
}