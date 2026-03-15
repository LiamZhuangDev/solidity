// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract NFTMarket {
    struct NFT {
        uint id;
        address owner;
        uint price;
        bool isForSale;
    }
    
    uint public nftCount;
    mapping(uint => NFT) public nfts; // id -> NFT
    uint[] public tokensForSale;

    function mint() external {
        uint id = nftCount++;
        nfts[id] = NFT({
            id: id,
            owner: msg.sender,
            price: 0,
            isForSale: false
        });
    }

    function listNFT(uint id, uint price) external {
        NFT storage nft = nfts[id];

        require(nft.owner == msg.sender, "not owner");
        require(!nft.isForSale, "already listed");
        require(price > 0, "invalid price");

        nft.price = price;
        nft.isForSale = true;

        tokensForSale.push(id);

    }

    function unlistNFT(uint id) external {
        require(id < nftCount, "invalid token id");
        NFT storage nft = nfts[id];
        require(nft.owner == msg.sender, "not owner");
        require(nft.isForSale, "not listed");

        nft.isForSale = false;
        nft.price = 0;

        _removeNFTForSale(id);
    }

    function buyNFT(uint id) external payable {
        require(id < nftCount, "invalid token id");
        NFT storage nft = nfts[id];
        require(nft.isForSale, "Not for sale");
        uint price = nft.price;
        require(msg.value == price, "Incorrect ETH amount");
        require(msg.sender != nft.owner, "cannot buy your own nft");

        address seller = nft.owner;
        nft.owner = msg.sender;
        nft.isForSale = false;
        nft.price = 0;

        (bool success, ) = payable(seller).call{value: price}("");
        require(success, "Transfer failed");
    }

    function getAllForSale() external view returns (uint[] memory) {
        return tokensForSale;
    }

    function _removeNFTForSale(uint id) private {
        require(id < nftCount, "invalid token id");
        uint len = tokensForSale.length;
        for (uint i = 0; i < len; i++) {
            if (tokensForSale[i] == id) {
                tokensForSale[i] = tokensForSale[len - 1];
                tokensForSale.pop();
                break;
            }
        }
    }
}