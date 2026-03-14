// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract UserAccountManager {
    struct UserInfo {
        string name;
        string email;
        uint balance;
        uint registeredAt;
        bool exists;
    }

    mapping(address => UserInfo) public users;
    address[] public userAddresses;
    uint public constant MAX_USERS = 1000;

    function register(string calldata name, string calldata email) public {
        require(bytes(name).length > 0, "Name is required");
        require(bytes(email).length > 0, "Email is required");
        require(!users[msg.sender].exists, "User already registered");
        require(userAddresses.length < MAX_USERS, "Maximum user reached");

        users[msg.sender] = UserInfo({
            name: name,
            email: email,
            balance: 0,
            registeredAt: block.timestamp,
            exists: true
        });

        userAddresses.push(msg.sender);
    }

    function updateProfile(string calldata name, string calldata email) public {
        require(bytes(name).length > 0, "Name is required");
        require(bytes(email).length > 0, "Email is required");    
        require(users[msg.sender].exists, "User not regiestered");

        users[msg.sender].name = name;
        users[msg.sender].email = email;
    }

    function deposit() public payable {
        require(users[msg.sender].exists, "User not regiestered");
        require(msg.value > 0, "Must send ETH");
        users[msg.sender].balance += msg.value;
    }

    function getMyInfo() public view returns (UserInfo memory) {
        require(users[msg.sender].exists, "User not registered");
        return users[msg.sender];
    }

    function isRegistered(address user) public view returns (bool) {
        return users[user].exists;
    }

    function getUserAddressByRange(uint start, uint end)
        public view returns (address[] memory result)
    {
        require(start < end, "invalid range");
        require(end <= userAddresses.length, "end out of bounds");

        uint len = end - start;
        result = new address[](len);
        for (uint i = 0; i < len; i++) {
            result[i] = userAddresses[i + start];
        }
    }

    function getUserInfoBatch(address[] calldata addrs) 
        public view returns (UserInfo[] memory result)
    {
        uint len = addrs.length;
        result = new UserInfo[](len);
        for (uint i = 0; i < len; i++) {
            result[i] = users[addrs[i]];
        }
    }
}