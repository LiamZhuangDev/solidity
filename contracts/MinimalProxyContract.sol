// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

// Contract template
contract TokenImplementation {
    string public name;
    string public symbol;
    address public creator;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    /*
    * @notice init function (replaces constructor)
    * @dev Clone cannot use constructor, so use initialize instead.
    */
    function initialize(
        string memory _name,
        string memory _symbol,
        uint256 _supply
    ) public {
        require(creator == address(0), "Already initialized");
        name = _name;
        symbol = _symbol;
        creator = msg.sender;
        totalSupply = _supply;
        balanceOf[msg.sender] = _supply;
    }

    function transfer(
        address to,
        uint256 amount
    ) public {
        require(balanceOf[msg.sender] >= amount, "Insufficient Funds");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
    }
}

contract CloneFactory {
    address public implementation;

    address[] public clones;

    constructor() {
        implementation = address(new TokenImplementation()); // deploy TokenImplementation contract
    }

    function createClone(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) public returns (address) {
        bytes memory bytecode = getCloneBytecode();
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, clones.length));

        // It calculates in advance the address where a clone will be deployed using `CREATE2`.
        address clone;
        assembly {
            clone := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }

        // TokenImplementation(clone): Treat this address as if it has the interface of TokenImplementation
        // Actual flow:
        // 1. call clone.initialize(...)
        // 2. clone fallback()
        // 3. delegatecall → implementation.initialize(...)
        // 4. logic executes
        // 5. storage written to clone
        TokenImplementation(clone).initialize(name, symbol, initialSupply);

        clones.push(clone);
        return clone;
    }

    function getCloneBytecode() internal view returns (bytes memory) {
        // EIP-1167 Minimal Proxy bytes
        // just for demo here, use OpenZeppelin for production env
        return abi.encodePacked(
            hex"3d602d80600a3d3981f3363d3d373d3d3d363d73",
            implementation,
            hex"5af43d82803e903d91602b57fd5bf3"
        );
    }
}