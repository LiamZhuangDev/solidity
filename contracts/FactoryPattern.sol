// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract SimpleToken {
    string public name;
    string public symbol;
    address public creator;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    constructor(string memory _name, string memory _symbol, uint256 _supply) {
        name = _name;
        symbol = _symbol;
        creator = msg.sender;
        totalSupply = _supply;
        balanceOf[msg.sender] = _supply;
    }

    function transfer(address to, uint256 amount) public {
        require(balanceOf[msg.sender] >= amount, "Insufficient Funds");

        balanceOf[to] += amount;
        balanceOf[msg.sender] -= amount;
    }
}

contract TokenFactory {
    SimpleToken[] public tokens;

    event TokenCreated(
        address indexed tokenAddress,
        string name,
        string symbol,
        address indexed creator
    );

    function createToken(
        string calldata name,
        string calldata symbol,
        uint256 initialSupply
    ) external returns (address) {
        SimpleToken newToken = new SimpleToken(name, symbol, initialSupply);

        tokens.push(newToken);

        emit TokenCreated(address(newToken), name, symbol, msg.sender);
        return address(newToken);
    }

    function getTokenCount() external view returns (uint256) {
        return tokens.length;
    }
}