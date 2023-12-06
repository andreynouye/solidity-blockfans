// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "../Structures/NFT.sol";
import "../Structures/NFTSource.sol";

interface ICreatorsNFT is IERC721 {
    event NFTTransferred(address indexed buyer, uint256 nftId);
    event Received(address indexed from, uint256 amount);
    event Recovered(
        address indexed sender,
        address tokenAddress,
        uint256 amountOrTokenId
    );

    function setNFTSource(
        string memory name,
        string memory description,
        string memory image,
        string memory external_url,
        uint256 price,
        uint256 units,
        NFTSource.MediaType mediaType
    ) external;

    function getNFTsByCreator(
        address creator
    ) external view returns (uint256[] memory);

    function getNFTDetailsByCreator(
        address creator
    ) external view returns (NFTSource.Detail[] memory);

    function deleteNFTSource(uint256 sourceId) external;

    function buyNFT(uint256 modelId) external;
}
