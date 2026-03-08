// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract SimpleToken {
    string public name = "SimpleToken";
    string public symbol = "MTK";
    uint8 public decimals = 18; // defines how many decimal places the token supports, same as ETH (1 ETH = 10^18 wei).
    uint256 public totalSupply;
    address public owner;
    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        // totalSupply = _initialSupply * (10 ** uint256(decimals));
        totalSupply = _initialSupply * (10 ** decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value)
        public returns (bool) {
            require(_to != address(0), "recipient cannot be zero address");
            require(balanceOf[msg.sender] >= _value, "insufficient balance");

            balanceOf[msg.sender] -= _value;
            balanceOf[_to] += _value;

            emit Transfer(msg.sender, _to, _value);
            return true;
        }

    function getBalance(address _curr)
        public view returns (uint256) {
            return balanceOf[_curr];
        }

    function mint(address _to, uint256 _amount) public {
        require(msg.sender == owner, "only owner can mint");
        require(_to != address(0), "cannot mint to zero address");

        balanceOf[_to] += _amount;
        totalSupply += _amount;

        emit Transfer(address(0), _to, _amount);
    }
}