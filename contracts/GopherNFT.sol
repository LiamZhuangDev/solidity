// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GopherNFT is ERC721, ERC721URIStorage, ERC2981, Ownable {
    uint256 private _tokenCount;

    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public mintPrice = 0.01 ether;

    event Minted(address indexed to, uint256 tokenId);

    constructor() ERC721("GopherNFT", "GONFT") Ownable(msg.sender) {
        _setDefaultRoyalty(msg.sender, 250); // 2.5% = 250 / 10000
    }

    function mint(string memory uri) public payable returns (uint256) {
        require(_tokenCount < MAX_SUPPLY, "Max Supply reached");
        require(msg.value >= mintPrice, "Insufficient funds");

        _tokenCount++;
        uint256 tokenId = _tokenCount;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        emit Minted(msg.sender, tokenId);

        return tokenId;
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "No funds");

        (bool success, ) = payable(owner()).call{value: amount}("");
        require(success, "withdraw failed");
    }

    function setMintPrice(uint256 price) public onlyOwner {
        require(price > 0, "Invalid price");
        mintPrice = price;
    }

    // Resolve multiple inheritance (diamond problem):
    // Both ERC721 and ERC721URIStorage implement tokenURI.
    // Solidity requires explicit override, and super.tokenURI()
    // follows C3 linearization to call the most derived implementation.
    function tokenURI(uint256 tokenId)
        public 
        view 
        override(ERC721, ERC721URIStorage) 
        returns (string memory) 
    {
        return super.tokenURI(tokenId);
    }

    // Resolve multiple inheritance (diamond problem)
    function supportsInterface(bytes4 interfaceId)
        public 
        view 
        override(ERC721, ERC721URIStorage, ERC2981) 
        returns (bool) 
    {
        return super.supportsInterface(interfaceId);
    }
}