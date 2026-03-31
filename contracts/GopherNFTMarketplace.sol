// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IERC2981 is IERC165 {
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        external view returns (address receiver, uint256 royaltyAmount);
}

contract GopherNFTMarketplace is ReentrancyGuard {
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool active;
    }

    struct Auction {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 startPrice;
        uint256 highestBid;
        address highestBidder;
        uint256 endTime;
        bool active;
    }

    mapping(uint256 => Listing) public listings; // listing Id => listed NFT
    uint256 public listingCount;

    mapping(uint256 => Auction) public auctions;
    uint256 public auctionCount;

    mapping(uint256 => mapping(address => uint256)) public pendingRefunds;

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

    event AuctionCreated(
        uint256 indexed auctionId,
        address indexed seller,
        address indexed nftContract,
        uint256 tokenId,
        uint256 startingPrice,
        uint256 endTime
    );

    event BidPlaced(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 amount
    );

    event BidEnded(
        uint256 indexed auctionId,
        address indexed winner,
        uint256 finalPrice
    );

    function ListingNFT(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) external returns (uint256) {
        require(price > 0, "Invalid price");
        require(nftContract != address(0), "Invalid NFT contract");

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

        require(listing.active, "NFT not active");
        require(listing.seller == msg.sender, "Not owner");

        listing.active = false;

        emit NFTDelisted(listingId, msg.sender);
    }

    function updatePrice(uint256 listingId, uint256 newPrice) external {
        require(newPrice > 0, "Invalid new price");

        Listing storage listing = listings[listingId];
        require(listing.seller == msg.sender, "Not owner");
        require(listing.active, "NFT not active");

        listing.price = newPrice;

        emit PriceUpdated(listingId, newPrice);
    }

    // fixed-price sales
    function buyNFT(uint256 listingId) external payable nonReentrant {
        Listing storage listing = listings[listingId];

        require(listing.active, "Not active");
        require(msg.value > listing.price, "Insufficient funds");
        require(msg.sender != listing.seller, "Cannot buy your own NFT");

        listing.active = false;

        uint256 fee = (listing.price * ListingFee) / 10000;

        (address royaltyReceiver, uint256 royaltyAmount) = _getRoyaltyInfo(
            listing.nftContract, 
            listing.tokenId, 
            listing.price);

        uint amountToSeller = listing.price - fee - royaltyAmount;

        IERC721(listing.nftContract).safeTransferFrom(
            listing.seller,
            msg.sender,
            listing.tokenId
        );

        if (royaltyAmount > 0 && royaltyReceiver != address(0)) {
            (bool successRoyalty, ) = payable(royaltyReceiver).call{value: royaltyAmount}("");
            require(successRoyalty, "Royalty transfer failed");
        }

        (bool successSeller, ) = payable(listing.seller).call{value: amountToSeller}("");
        require(successSeller, "Seller transfer failed");

        (bool successFee, ) = payable(feeRecipient).call{value: fee}("");
        require(successFee, "Fee transfer failed");

        if (msg.value > listing.price) {
            (bool successRefund, ) = msg.sender.call{value: msg.value - listing.price}("");
            require(successRefund, "Refund failed");
        }

        emit NFTSold(listingId, msg.sender, listing.seller, listing.price);
    }

    function _getRoyaltyInfo(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) internal view returns (address receiver, uint256 royaltyAmount) {
        if (IERC165(nftContract).supportsInterface(type(IERC2981).interfaceId)) {
            (receiver, royaltyAmount) = IERC2981(nftContract).royaltyInfo(tokenId, price);
        } else {
            receiver = address(0);
            royaltyAmount = 0;
        }
    }
}