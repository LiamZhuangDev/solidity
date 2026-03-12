// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract SafeIteration {
    uint[] public data;
    uint public constant MAX_SIZE = 100;

    /// @notice Avoid unbounded loops, append a value if the array has not reached MAX_SIZE.
    function safePush(uint value) public 
    {
        require(data.length < MAX_SIZE, "Array is full");
        data.push(value);
    }

    /// @notice Batch processing, Sum values in the range [start, end).
    function sumRange(uint start, uint end) 
        public view returns (uint) {
        require(start < end, "Invalid range");
        require(end <= data.length, "End index out of bounds");

        uint total = 0;
        for (uint i = start; i < end; i++) {
            total += data[i];
        }

        return total;
    }

    function removeOrdered(uint index) public {
        uint len = data.length;
        require(index < len, "index out of bounds");

        for (uint i = index; i < len - 1;) {
            data[i] = data[i + 1];
            unchecked { i++; }
        }

        data.pop();
    }

    function deleteRangeOrderPreserved(uint start, uint count) public
    {
        uint len = data.length;
        require(start + count < len, "param out of bounds");

        uint newLen = len - count; // the element with index (len - count - 1) is the last one we need to shift to left
        for (uint i = start; i < newLen;)
        {
            data[i] = data[i + count];
            unchecked { i++; }
        }

        assembly {
            sstore(data.slot, newLen)
        }
    }

    /// @notice User-triggered iteration, return a paginated slice of the array.
    function getPage(uint pageNumber, uint pageSize)
        public view returns (uint[] memory) 
    {
        require(pageNumber > 0, "Page number must be greater than 0");
        require(pageSize > 0 && pageSize <= 20, "Page size must be greater than 0 and less than 21");

        uint len = data.length;
        uint start = pageNumber * pageSize;
        require(start < len, "Page out of bounds");

        uint end = start + pageSize;
        if (end > len) {
            end = len;
        }

        uint resultLen = end - start;
        uint[] memory result = new uint[](resultLen);
        uint j = 0;
        for (uint i = start; i < end;) {
            result[j] = data[i];
            unchecked {
                i++;
                j++;
            }
        }
        
        return result;
    }

    /// @notice Instead of returning data, return range indices to front-end to save gas.
    function getPage2(uint pageNumber, uint pageSize)
        public view returns (uint start, uint end)
    {
        uint len = data.length;

        start = pageNumber * pageSize;
        if (start >= len) return (0, 0);

        end = start + pageSize;
        if (end > len) end = len;
    }
}