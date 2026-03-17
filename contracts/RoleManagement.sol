// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract RoleManagement {
    enum Role { None, User, Admin, Owner }
    mapping(address => Role) public roles;
    address public owner;

    constructor() {
        owner = msg.sender;
        roles[msg.sender] = Role.Owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier onlyAdmin() {
        require(roles[msg.sender] >= Role.Admin, "not admin or owner");
        _;
    }

    function addAdmin(address user) public onlyOwner {
        require(user != address(0), "invalid address");
        require(roles[user] != Role.Owner, "cannot change owner role");
        roles[user] = Role.Admin;
    }

    function addUser(address user) public onlyAdmin {
        require(user != address(0), "invalid address");
        require(roles[user] == Role.None, "user already has a role");
        roles[user] = Role.User;
    }
}