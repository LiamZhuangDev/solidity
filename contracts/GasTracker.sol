// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract GasTracker {
    function getGas() public view returns (uint gasUsed) {
        uint gasBefore = gasleft();

        // any logic need to be monitor gas usage
        
        gasUsed = gasBefore - gasleft();
    }
}