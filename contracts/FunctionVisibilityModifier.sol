// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract Callee {
    function publicFunc() public pure returns (string memory) {
        return "This is a public function";
    }

    function callPublicFuncInsideContract() public pure returns (string memory) {
        return publicFunc();
    }

    function externalFunc() external pure returns (string memory) {
        return "This is an external function";
    }

    // save gas by using calldata in external/public functions
    function externalArrSum(uint[] calldata arr)
        external pure returns (uint) {
        uint sum = 0;
        uint len = arr.length;
        for (uint i = 0; i < len; i++) {
            sum += arr[i];
        }
        return sum;
    }

    // this is actually an external call, uses more gas, which is not recommended
    function callExternalFuncInsideContract() external view returns (string memory) {
        return this.externalFunc();
    }
}

contract Caller {
    Callee public callee;

    constructor(address _addr) {
        // Cast the address to the Callee contract type so we can call its functions,
        // It creates a reference to an already deployed Callee contract at address `_addr`.
        callee = Callee(_addr);
    }

    function callPublicFunc() public view returns (string memory) {
        return callee.publicFunc();
    }

    function callExternalFunc() public view returns (string memory) {
        return callee.externalFunc();
    }
}