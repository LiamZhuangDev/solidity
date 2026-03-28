// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract PackedConfiguration {
    uint256 public data;

    uint256 private constant LTV_MASK = 0xFFFF;                       // 第0-15位：LTV
    uint256 private constant LIQUIDATION_THRESHOLD_MASK = 0xFFFF0000; // 第16-31位：清算阈值
    uint256 private constant LIQUIDATION_BONUS_MASK = 0xFFFF00000000; // 第32-47位：清算奖励
    uint256 private constant DECIMALS_MASK = 0xFF000000000000;        // 第48-55位：小数位
    uint256 private constant IS_ACTIVE_MASK = 0x100000000000000;      // 第56位：是否激活

    function setLTV(uint256 ltv) external {
        // clear current LTV
        data &= ~LTV_MASK;
        // set new LTV
        data |= ltv & LTV_MASK;
    }

    function getLTV() external view returns (uint256) {
        return data & LTV_MASK;
    }

    function setLiquidationThreshold(uint256 threshold) external {
        // clear current liquidation threshold
        data &= ~LIQUIDATION_THRESHOLD_MASK;
        // set new liquidation threshold
        data |= (threshold << 16) & LIQUIDATION_BONUS_MASK;
    }

    // other gets and sets
}