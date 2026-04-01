// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

library GopherPaymentLib {
    function distribute(
        address seller,
        address feeRecipient,
        address royaltyReceiver,
        uint256 price,
        uint256 fee,
        uint256 royalty
    ) internal {
        uint256 sellerAmount = price - fee - royalty;

        if (royalty > 0 && royaltyReceiver != address(0)) {
            (bool r, ) = royaltyReceiver.call{value: royalty}("");
            require(r, "Royalty failed");
        }

        (bool s, ) = seller.call{value: sellerAmount}("");
        require(s, "Seller failed");

        (bool f, ) = feeRecipient.call{value: fee}("");
        require(f, "Fee failed");
    }
}