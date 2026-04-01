// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import "./GopherPaymentLib.sol";
import "./GopherRoyaltyLib.sol";

// Design Overview:
// User
//  ↓
// Marketplace (entry point / orchestrator)
//  ├─ Fixed-price sales (list → buy)
//  └─ Delegates auctions → AuctionHouse
//                           ├─ createAuction
//                           ├─ placeBid
//                           └─ endAuction

interface IAuctionHouse {
    function createAuction(
        address seller,
        address nft,
        uint256 tokenId,
        uint256 startPrice,
        uint256 duration
    ) external returns (uint256);
    
    function isActive(address nft, uint256 tokenId) external view returns (bool);
}

contract GopherNFTMarketplace is ReentrancyGuard {
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool active;
    }

    mapping(uint256 => Listing) public listings; // listing Id => listed NFT
    mapping(address => mapping(uint256 => bool)) public isListed; // nft => tokenId => isListed
    uint256 public listingCount;

    IAuctionHouse public auction;

    // mapping(uint256 => mapping(address => uint256)) public pendingRefunds;

    uint256 public constant ListingFee = 250; // 2.5% = 250 / 10,000

    address public feeRecipient;

    event NFTListed(
        uint256 indexed listingId,
        address indexed seller,
        address indexed nftContract,
        uint256 tokenId,
        uint256 price
    );

    event NFTDelisted(
        uint256 indexed listingId,
        address indexed seller
    );

    event PriceUpdated(
        uint256 indexed listingId,
        uint256 newPrice
    );

    event NFTSold(
        uint256 indexed listingId,
        address indexed buyer,
        address indexed seller,
        uint256 price
    );

    constructor(address _auction, address _feeRecipient) {
        auction = IAuctionHouse(_auction);
        feeRecipient = _feeRecipient;
    }

    // =========================== LISTING ==============================
    function ListNFT(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) external returns (uint256) {
        require(price > 0, "Invalid price");
        require(nftContract != address(0), "Invalid NFT contract");
        require(!isListed[nftContract][tokenId], "Already listed");
        require(!auction.isActive(nftContract, tokenId), "In auction");

        IERC721 nft = IERC721(nftContract);

        require(nft.ownerOf(tokenId) == msg.sender, "Not owner");

        require(
            nft.getApproved(tokenId) == address(this) ||
            nft.isApprovedForAll(msg.sender, address(this)),
            "Marketplace not approved");

        listingCount++;
        listings[listingCount] = Listing({
            seller: msg.sender,
            nftContract: nftContract,
            tokenId: tokenId,
            price: price,
            active: true
        });
        isListed[nftContract][tokenId] = true;

        emit NFTListed(
            listingCount,
            msg.sender,
            nftContract,
            tokenId,
            price
        );

        return listingCount; // listing ID
    }

    function delist(uint256 listingId) external {
        Listing storage listing = listings[listingId];

        require(listing.active, "NFT not listed");
        require(listing.seller == msg.sender, "Not owner");

        listing.active = false;
        isListed[listing.nftContract][listing.tokenId] = false;

        emit NFTDelisted(listingId, msg.sender);
    }

    function updatePrice(uint256 listingId, uint256 newPrice) external {
        require(newPrice > 0, "Invalid new price");

        Listing storage listing = listings[listingId];
        require(listing.seller == msg.sender, "Not owner");
        require(listing.active, "NFT not listed");

        listing.price = newPrice;

        emit PriceUpdated(listingId, newPrice);
    }

    // fixed-price sales
    function buyNFT(uint256 listingId) external payable nonReentrant {
        Listing storage l = listings[listingId];

        require(l.active, "Inactive");
        require(msg.value > l.price, "Insufficient funds");
        require(msg.sender != l.seller, "Cannot buy your own NFT");

        l.active = false;
        isListed[l.nftContract][l.tokenId] = false;
        uint256 fee = (l.price * ListingFee) / 10000;

        (address royaltyReceiver, uint256 royaltyAmount) = GopherRoyaltyLib.getRoyaltyInfo(
            l.nftContract,
            l.tokenId,
            l.price);

        GopherPaymentLib.distribute(l.seller, feeRecipient, royaltyReceiver, l.price, fee, royaltyAmount);

        emit NFTSold(listingId, msg.sender, l.seller, l.price);
    }

    // =========================== Auction ==============================
    function createAuction(
        address nft,
        uint256 tokenId,
        uint256 startPrice,
        uint256 duration
    ) external {
        require(!isListed[nft][tokenId], "Already listed");
        require(!auction.isActive(nft, tokenId), "In auction");
        require(IERC721(nft).ownerOf(tokenId) == msg.sender, "Not owner");

        IERC721(nft).transferFrom(msg.sender, address(auction), tokenId);

        auction.createAuction(msg.sender, nft, tokenId, startPrice, duration);
    }
}