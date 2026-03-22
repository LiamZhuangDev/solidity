// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

library EnumerableAddressSet {
    struct AddressSet {
        address[] addresses;
        mapping(address => uint256) indexOf; // address => 1-based index
    }

    function add(AddressSet storage set, address addr) internal returns (bool) {
        if (contains(set, addr)) {
            return false;
        }

        set.addresses.push(addr);
        set.indexOf[addr] = set.addresses.length;

        return true;
    }

    function remove(AddressSet storage set, address addr) internal returns (bool) {
        if (!contains(set, addr)) {
            return false;
        }

        uint index = set.indexOf[addr];
        uint indexToDelete = index - 1; // 1-based index so need to Subtract 1
        uint last = set.addresses.length - 1;

        if (indexToDelete != last) {
            address lastAddr = set.addresses[last];
            set.addresses[indexToDelete] = lastAddr;
            set.indexOf[lastAddr] = index;
        }

        delete set.indexOf[addr];
        set.addresses.pop();

        return true;
    }

    function contains(AddressSet storage set, address addr) internal view returns (bool) {
        return set.indexOf[addr] != 0;
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return set.addresses.length;
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        uint256 i = index - 1;
        require(i < set.addresses.length, "index out of bounds");
        return set.addresses[i];
    }
}

contract whitelistExample {
    using EnumerableAddressSet for EnumerableAddressSet.AddressSet;

    EnumerableAddressSet.AddressSet private whitelist;

    function addToWhitelist(address addr) public {
        bool success = whitelist.add(addr);
        require(success, "failed to add the address to the whitelist");
    }

    function removeFromWhitelist(address addr) public {
        bool success = whitelist.remove(addr);
        require(success, "failed to remove the address from the whitelist");
    }

    function isWhitelisted(address addr) public view returns (bool) {
        return whitelist.contains(addr);
    }
}