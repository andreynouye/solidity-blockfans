// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

library Key {
    struct Detail {
        uint256 keyId;
        address creator;
        string name;
        string description;
        string image;
        string external_url;
        uint256 duration;
        uint256 price;
    }
}
