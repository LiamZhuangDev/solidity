// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract A {
    event Log(string message);

    constructor() {
        emit Log("ctor A");
    }

    function foo() public virtual returns (string memory) {
        return "A";
    }
}

contract B is A {
    constructor() {
        emit Log("ctor B");
    }

    function foo() public virtual override returns (string memory) {
        return string.concat("B->", super.foo());
    }
}

contract C is A {
    constructor() {
        emit Log("ctor C");
    }

    function foo() public virtual override returns (string memory) {
        return string.concat("C->", super.foo());
    }
}

contract D is B, C {
    constructor() {
        emit Log("ctor D");
    }

    function foo() public override(B, C) returns (string memory) {
        return string.concat("D->", super.foo()); // D->C->B-A
    }
}