// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./GopherPaymentLib.sol";
import "./GopherRoyaltyLib.sol";

contract GopherAuctionHouse is ReentrancyGuard {
    struct Auction {
        address seller;
        address nft;
        uint256 tokenId;
        uint256 highestBid;
        address highestBidder;
        uint256 endTime;
        bool active;
    }

    uint256 public auctionId;
    uint256 public AuctionFee = 500; // 5% = 500 / 10000
    address public feeRecipient;
    mapping(uint256 => Auction) public auctions; // auctionId => auction
    mapping(address => mapping(uint256 => bool)) public activeAuction; // nft => token Id => active
    mapping(uint256 => mapping(address => uint256)) public refunds; // auction Id? => account => amount

    event AuctionCreated(
        uint256 indexed auctionId,
        address indexed seller,
        address indexed nftContract,
        uint256 tokenId,
        uint256 startPrice,
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

    constructor(address _feeRecipient) {
        feeRecipient = _feeRecipient;
    }

    function createAuction(
        address seller,
        address nft,
        uint256 tokenId,
        uint256 startPrice,
        uint256 duration
    ) external returns (uint256) {
        auctionId++;

        auctions[auctionId] = Auction({
            seller: seller,
            nft: nft,
            tokenId: tokenId,
            highestBid: startPrice,
            highestBidder: address(0),
            endTime: block.timestamp + duration,
            active: true
        });
        activeAuction[nft][tokenId] = true;

        emit AuctionCreated(auctionId, seller, nft, tokenId, startPrice, block.timestamp + duration);

        return auctionId;
    }

    function placeBid(uint256 id) external payable {
        Auction storage a = auctions[id];

        require(a.active, "inactive");
        require(block.timestamp < a.endTime, "ended");
        require(msg.value > a.highestBid, "low bid");

        if (a.highestBidder != address(0)) {
            refunds[id][a.highestBidder] += a.highestBid;
        }

        a.highestBid = msg.value;
        a.highestBidder = msg.sender;

        emit BidPlaced(id, msg.sender, msg.value);
    }

    function withdraw(uint256 id) external nonReentrant {
        uint256 amount = refunds[id][msg.sender];
        require(amount > 0, "no funds");

        refunds[id][msg.sender] = 0;

        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "refund failed");
    }

    function endAuction(uint256 id) external nonReentrant {
        Auction storage a = auctions[id];

        require(a.active, "inactive");
        require(block.timestamp >= a.endTime, "not ended");

        a.active = false;
        activeAuction[a.nft][a.tokenId] = false;

        if (a.highestBidder != address(0)) {
            IERC721(a.nft).safeTransferFrom(address(this), a.highestBidder, a.tokenId);

            uint256 fee = (a.highestBid * AuctionFee) / 10000;

            (address royaltyReceiver, uint256 royaltyAmount) = GopherRoyaltyLib.getRoyaltyInfo(
                a.nft,
                a.tokenId,
                a.highestBid);

            GopherPaymentLib.distribute(a.seller, feeRecipient, royaltyReceiver, a.highestBid, fee, royaltyAmount);
        } else {
            // no bids → return NFT
            IERC721(a.nft).safeTransferFrom(address(this), a.seller, a.tokenId);
        }

        emit BidEnded(id, a.highestBidder, a.highestBid);
    }

    function isActive(address nft, uint256 tokenId) external view returns (bool) {
        return activeAuction[nft][tokenId];
    }
}