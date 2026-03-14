// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract StorageStruct {
    struct User {
        string name;
        uint age;
    }

    User public admin;
    mapping(address => User) public userMap;

    function updateAdmin(string calldata name, uint age) public {
        admin.name = name;
        admin.age += age;
    }

    function updateMyInfo(string calldata name, uint age) public {
        User storage u = userMap[msg.sender]; // create a storage reference points to the current user in storage
        u.name = name;
        u.age = age;
    }
}

contract MemoryStruct {
    struct User {
        string name;
        uint age;
    }

    User[] public users;

    function createMemoryUser() public pure returns (User memory) {
        User memory user = User({
            name: "memory user",
            age: 18
        });
        return user;
    }

    function processUser() public view {
        User memory user = users[0]; // copy to memory
        user.age = 30; // modify the copy, doesn't affect the user in storage
    }
}

contract CalldataStruct {
    struct User {
        string name;
        uint age;
    }

    function processUser(User calldata u) 
        external pure returns (string memory)
    {
        //u.age = 30; // compiler error, calldata structs are read-only
        return u.name;
    }
}