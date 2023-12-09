// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

library KeySource {
    enum Status {
        Pending,
        Available,
        SoldOut,
        Trashed,
        Blocked,
        Banned
    }

    struct Detail {
        uint256 keySourceId;
        address creator;
        string name;
        string description;
        string image;
        string external_url;
        uint256 duration;
        uint256 price;
        uint256 units;
        Status status;
    }
}
