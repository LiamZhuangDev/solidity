// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract MultiDimensionalArray {
    
    uint[][] public matrix; // Dynamic two-dimensional array

    uint[2][3] public fixedMatrix; // fixed-size array with 3 elements, where each element is an array of 2 uint256 values (3 rows and 2 columns)

    uint[][5] public dynamicMatrix; // fixed-size array (5) where each element is a dynamic uint256 array

    uint[3][] public triplets; // dynamic array of fixed-size arrays (3 uint256 values each)

    function addRow(uint[] calldata row) public
    {
        matrix.push(row);
    }

    function initMatrix() public
    {
        delete matrix;

        matrix.push([1,2,3]);

        uint[] memory row2 = new uint[](3);
        row2[0] = 4;
        row2[1] = 5;
        row2[2] = 6;
        matrix.push(row2);
    }

    function getElement(uint row, uint col)
        public view returns (uint) 
    {
        uint rowSize = matrix.length;
        uint colSize = matrix[row].length;
        require(row < rowSize, "row out of bounds");
        require(col < colSize, "col out of bounds");

        return matrix[row][col];
    }

    function getRow(uint row)
        public view returns (uint[] memory)
    {
        uint rowSize = matrix.length;
        require(row < rowSize, "row out of bounds");
        
        return matrix[row];
    }

    function setElement(uint row, uint col, uint value) public
    {
        uint rowSize = matrix.length;
        uint colSize = matrix[row].length;
        require(row < rowSize, "row out of bounds");
        require(col < colSize, "col out of bounds");

        matrix[row][col] = value;
    }

    function findElement(uint value)
        public view returns (bool, uint, uint)
    {
        uint rowSize = matrix.length;
        
        for (uint i = 0; i < rowSize;) {
            uint colSize = matrix[i].length;
            for (uint j = 0; j < colSize;) {
                if (matrix[i][j] == value) {
                    return (true, i, j);
                }
                
                unchecked {
                    j++;
                }
            }

            unchecked {
                i++;
            }
        }

        return (false, 0, 0);
    }

    // Assume each row has the same number of elements
    function getDimensions() public view returns (uint rowSize, uint colSize)
    {
        rowSize = matrix.length;
        if (rowSize > 0) {
            colSize = matrix[0].length;
        } else {
            colSize = 0;
        }
    }

    function sumMatrix() public view returns (uint)
    {
        uint total = 0;
        uint rowSize = matrix.length;

        for (uint i = 0; i < rowSize; i++) {
            uint colSize = matrix[i].length;
            for (uint j = 0; j < colSize; j++) {
                total += matrix[i][j];
            }
        }

        return total;
    }
}