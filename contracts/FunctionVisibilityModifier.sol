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

    // save gas by using calldata for big array in external/public functions
    // one exception is calling public func with calldata inside of the contract, it will copy arr to memory
    // because there aren't calldata input buffers in internal calls.
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

    function _internalFunc() internal pure returns (string memory) {
        return "This is an internal function";
    }

    function callInternalFuncInsideContract() external pure returns (string memory) {
        return _internalFunc();
    }

    // only accessible within the contract
    function _secretFunc() private pure returns (string memory) {
        return "secret message";
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

    // function callInternalFunc() public view returns (string memory) {
    //     return callee._internalFunc(); // not found
    // }

    // function callPrivateFuncFromBase() public pure returns (string memory) {
    //     return callee._secretFunc(); // not found
    // }
}

contract InheritedCallee is Callee {
    function callInternalFuncFromBase() public pure returns (string memory) {
        return _internalFunc();
    }

    // this is actually external call and EVM copies arr to calldata, NOT recommended!
    // should use internal + external wrapper
    function callExternalFuncFromBase() public view returns (uint) {
        uint[] memory arr = new uint[](2);
        arr[0] = 1;
        arr[1] = 2;
        return this.externalArrSum(arr);
    }

    // function callPrivateFuncFromBase() public pure returns (string memory) {
    //     return _secretFunc(); // not found
    // }
}