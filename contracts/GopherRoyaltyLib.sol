// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

library GopherRoyaltyLib {
    function getRoyaltyInfo(
        address nft,
        uint256 tokenId,
        uint256 price
    ) internal view returns (address receiver, uint256 royaltyAmount) {
        if (IERC165(nft).supportsInterface(type(IERC2981).interfaceId)) {
            try IERC2981(nft).royaltyInfo(tokenId, price) returns (address r, uint256 a) {
                return (r, a);
            } catch {
                // malicious or broken contract
                return (address(0), 0);
            }
        }

        return (address(0), 0);
    }
}