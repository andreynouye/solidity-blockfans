// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

library Plan {
    enum Status {
        Pending,
        Available,
        SoldOut,
        Trashed,
        Blocked,
        Banned
    }

    struct Detail {
        uint256 planId;
        address creator;
        string name;
        string description;
        string external_url;
        uint256 duration;
        uint256 price;
        uint256 units;
        Status status;
    }
}
