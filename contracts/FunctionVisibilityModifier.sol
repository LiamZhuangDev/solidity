// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract Callee {
    uint public value;

    function getValue() public view returns (uint) {
        return value;
    }

    function testPublicFunctionInsideContract() public view returns (uint) {
        return getValue();
    }
}

contract Caller {
    Callee public callee;

    constructor(address _addr) {
        // Cast the address to the Callee contract type so we can call its functions,
        // It creates a reference to an already deployed Callee contract at address `_addr`.
        callee = Callee(_addr);
    }

    function callPublicFunc() public view returns (uint) {
        return callee.getValue();
    }
}