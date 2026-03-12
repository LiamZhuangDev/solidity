// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract ArrayGasOptimization {
    uint[] public data;

    function add(uint[] memory values) public {
        for (uint i = 0; i < values.length; i++) {
            if (values[i] > 10) {
                data.push(values[i]);
            }
        }
    }

    // add2 actually uses more gas than add function above
    function add2(uint[] calldata values) public {
        uint len = values.length;
        uint[] memory temp = new uint[](len);
        uint count = 0;

        for (uint i = 0; i < len; i++) {
            if (values[i] > 10) {
                temp[count] = values[i];
                count++;
            }
        }

        for (uint i = 0; i < count; i++) {
            data.push(temp[i]);
        }
    }

    function add3(uint[] calldata values) public {
        uint inputLen = values.length;
        uint origLen = data.length;
        uint count = 0;

        for (uint i = 0; i < inputLen; i++) {
            if (values[i] > 10) {
                count++;
            }
        }

        if (count > 0) {
            uint newLen = origLen + count;
            assembly {
                sstore(data.slot, newLen)
            }

            uint tail = origLen;
            for (uint i = 0; i < inputLen; i++) {
                if (values[i] > 10) {
                    data[tail] = values[i];
                    tail++;
                }
            }
        }
    }

    function add4(uint[] memory values) public {
        uint inputLen = values.length;
        uint origLen = data.length;

        // temporary expansion
        uint newLen = origLen + inputLen;
        assembly {
            sstore(data.slot, newLen)
        }

        uint tail = origLen;
        for (uint i = 0; i < inputLen; i++) {
            if (values[i] > 10) {
                data[tail] = values[i];
                tail++;
            }
        }

        // Shrink to actual size
        assembly {
            sstore(data.slot, tail)
        }
    }

    // 2031292 execution gas cost when n = 100
    // 4304253 execution gas cost when n = 200
    // 11260496 execution gas cost when n = 500
    function testAdd(uint n) external {
        uint[] memory arr = new uint[](n);

        for (uint i = 0; i < n; i++) {
            arr[i] = i;
        }

        add(arr); 
    }

    // 2086591 execution gas cost when n = 100
    // 4416993 execution gas cost when n = 200
    // 11409368 execution gas cost when n = 500
    function testAdd2(uint n) external {
        uint[] memory arr = new uint[](n);

        for (uint i = 0; i < n; i++) {
            arr[i] = i;
        }

        this.add2(arr); // 'this.' forces an external call, which encodes arr into calldata automatically
    }

    // 2084934 execution gas cost when n = 100
    // 4411575 execution gas cost when n = 200
    // 11392434 execution gas cost when n = 500
    function testAdd3(uint n) external {
        uint[] memory arr = new uint[](n);

        for (uint i = 0; i < n; i++) {
            arr[i] = i;
        }

        this.add3(arr);
    }

    // 2059796 execution gas cost when n = 100
    // 4359737 execution gas cost when n = 200
    // 11143942 execution gas cost when n = 500
    function testAdd4(uint n) external {
        uint[] memory arr = new uint[](n);

        for (uint i = 0; i < n; i++) {
            arr[i] = i;
        }

        add4(arr);
    }
}

