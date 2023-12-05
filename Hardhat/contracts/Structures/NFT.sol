// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./NFTSource.sol";

library NFT {
    struct Detail {
        uint256 tokenId;
        address creator;
        string name;
        string description;
        string image;
        string external_url;
        uint256 price;
        NFTSource.MediaType mediaType;
    }
}
