// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract ImplementationV1 {
    uint256 public value;
    address public owner;

    function setValue(uint256 _value) external {
        value = _value;
        owner = msg.sender;
    }

    function getValue() external view returns (uint256) {
        return value;
    }
}

contract ImplementationV2 {
    uint256 public value;
    address public owner;

    function setValue(uint256 _value) external {
        value = _value * 2;
        owner = msg.sender;
    }

    function getValue() external view returns (uint256) {
        return value;
    }

    function reset() external {
        value = 0;
    }
}

contract Proxy {
    // MUST match Implementation layout first
    uint256 public value;
    address public owner;

    // Put proxy-specific variables after
    address public implementation;

    event Upgraded(address indexed newImplementation);

    constructor(address _implementation) {
        implementation = _implementation;
        owner = msg.sender;
    }

    function upgrade(address newImplementation) external {
        require(msg.sender == owner, "Not Owner");
        implementation = newImplementation;
        emit Upgraded(newImplementation);
    }

    fallback() external payable {
        address impl = implementation;
        require(impl != address(0), "Implementation not set");

        (bool success, bytes memory returnData) = impl.delegatecall(msg.data);
        if (!success) {
            assembly {
                returndatacopy(0, 0, returndatasize()) // copies revert reason / error data into memory. returndatacopy(destOffset, srcOffset, size),
                revert(0, returndatasize()) // reverts using the exact same data, revert(memoryOffset, size)
            }
        }

        assembly {
            // returnData: [length(32 bytes)][ actual data...]
            // mload(ptr) = load 32 bytes from memory, so mload(returnData) reads the length of returnData
            // add(returnData, 0x20) skips the length and points to the actual data
            // return(ptr, size) returns exact same bytes as implementation
            return(add(returnData, 0x20), mload(returnData))
        }
    }

    receive() external payable { }
}