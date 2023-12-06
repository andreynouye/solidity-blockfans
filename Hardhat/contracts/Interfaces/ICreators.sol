// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface ICreators {
    event Received(address indexed from, uint256 amount);
    event Recovered(
        address sender,
        address tokenAddress,
        uint256 amountOrTokenId
    );

    function getCreators() external view returns (address[] memory);
}
