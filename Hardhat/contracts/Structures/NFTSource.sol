// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

library NFTSource {
    enum MediaType {
        Unavailable,
        Image,
        Video,
        Audio,
        Text,
        Other
    }

    enum Status {
        Pending,
        Available,
        Unavailable,
        Blocked,
        Banned
    }

    struct Detail {
        uint256 sourceId;
        address creator;
        string name;
        string description;
        string image;
        string external_url;
        uint256 price;
        uint256 units;
        MediaType mediaType;
        Status status;
    }
}
