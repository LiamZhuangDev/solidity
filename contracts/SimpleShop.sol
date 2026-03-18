// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract SimpleShop {
    address public immutable OWNER;
    uint public constant ITEM_PRICE = 0.1 ether;
    mapping(address => uint) purchaseOf;

    constructor() {
        OWNER = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == OWNER, "Not owner");
        _;
    }

    function buyItem(uint quantity) public payable {
        require(quantity > 0, "invalid quantity");
        uint cost = ITEM_PRICE * quantity;
        require(msg.value == cost, "invalid amount");

        purchaseOf[msg.sender] += quantity;
    }

    function getPurchase(address buyer) public view returns (uint) {
        return purchaseOf[buyer];
    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "no balance");

        (bool success, ) = payable(OWNER).call{value: balance}("");
        require(success, "withdraw failed");
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}