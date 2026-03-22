// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract Ownable2 {
    address public owner;
    
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    constructor(address _owner) {
        owner = _owner;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Pausable {
    bool public paused;

    event Paused(address account);
    event Unpaused(address account);

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "Contract is not paused");
        _;
    }

    function _pause() internal whenNotPaused {
        paused = true;
    }

    function _unpause() internal whenPaused {
        paused = false;
    }
}

contract MyContract is Ownable2, Pausable {
    uint256 public value;

    constructor() Ownable2(msg.sender) {}

    function setValue(uint256 _value) public onlyOwner {
        value = _value;
    }
    
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}

// =====================Abstract Contract==================================

abstract contract Animal {
    string public species;

    constructor(string memory _species) {
        species = _species;
    }

    function makeSound() public virtual returns (string memory);

    function eat() public pure returns (string memory) {
        return "I'm eating...";
    }

    function sleep() public pure returns (string memory) {
        return "I'm sleeping...";
    }
}

contract Dog is Animal {
    constructor() Animal("Dog") {}

    function makeSound() public pure override returns (string memory) {
        return "Woof";
    }
}

contract Cat is Animal {
    constructor() Animal("Cat") {}

    function makeSound() public pure override returns (string memory) {
        return "Meow";
    }
}

// ==========================My Token(derives from OpenZeppelin)=============================
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    constructor(uint256 initialSupply) ERC20("My Token", "MTK") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}