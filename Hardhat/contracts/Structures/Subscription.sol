// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

library Subscription {
    struct Detail {
        uint256 subscriptionId;
        uint256 planId;
        uint256 startDate;
        uint256 duration;
    }
}
