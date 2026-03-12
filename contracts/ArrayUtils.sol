// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract ArrayUtils {
    uint[] public data;
    uint public constant MAX_SIZE = 100;

    function safePush(uint value) public {
        require(data.length < MAX_SIZE, "Array too large");
        data.push(value);
    }

    function removeOrdered(uint index) public {
        uint len = data.length;
        require(index < len, "index out of bounds");
        for (uint i = index; i < len - 1;) {
            data[i] = data[i+1];
            unchecked { i++; }
        }
        data.pop();
    }

    function removeOrdered2(uint index) public {
        uint len = data.length;
        require(index < len, "index out of bounds");
        
        uint[] memory temp = new uint[](len);
        for (uint i = 0; i < len;) {
            temp[i] = data[i];
            unchecked { i++; }
        }

        for (uint i = index; i < len - 1;) {
            temp[i] = temp[i + 1];
            unchecked { i++; }
        }

        data = temp;
    }

    function removeUnordered(uint index) public {
        uint len = data.length;
        require(index < len, "index out of bounds");

        data[index] = data[len - 1];
        data.pop();
    }

    function sumRange(uint start, uint end) 
        public view returns (uint)
    {
        uint len = data.length;
        require(start < end, "start must be <= end");
        require(end <= len, "end out of bounds");

        uint total = 0;
        for (uint i = start; i < end;) {
            total += data[i];
            unchecked { i++; }
        }
        return total;
    }

    function containsElement(uint value) 
        public view returns (bool, uint)
    {
        uint len = data.length;

        for (uint i = 0; i < len;) {
            if (data[i] == value) {
                return (true, i);
            }
            unchecked{i++;}
        }

        return (false, 0);
    }

    function getAll() public view returns (uint[] memory)
    {
        return data;
    }
}