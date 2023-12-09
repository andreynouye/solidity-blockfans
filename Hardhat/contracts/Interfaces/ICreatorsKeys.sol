// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "../Structures/Key.sol";
import "../Structures/KeySource.sol";

interface ICreatorsKeys is IERC721 {
    event KeyTransferred(address indexed buyer, uint256 nftId);
    event Received(address indexed from, uint256 amount);
    event Recovered(
        address indexed sender,
        address tokenAddress,
        uint256 amountOrTokenId
    );

    function setKeySource(
        string memory name,
        string memory description,
        string memory image,
        string memory external_url,
        uint256 duration,
        uint256 price,
        uint256 units
    ) external;

    function getKeysByCreator() external view returns (uint256[] memory);

    function getKeyDetailsByCreator()
        external
        view
        returns (KeySource.Detail[] memory);

    function getPublicKeysByCreator(
        address creator
    ) external view returns (uint256[] memory);

    function getPublicKeyDetailsByCreator(
        address creator
    ) external view returns (KeySource.Detail[] memory);

    function getSoldUnitsPerSource(
        uint256 tokenId
    ) external view returns (uint256);

    function deleteKeySource(uint256 sourceId) external;

    function permanentDeleteKeySource(uint256 sourceId) external;

    function restoreKeySource(uint256 sourceId) external;

    function buyKey(uint256 modelId) external;
}
