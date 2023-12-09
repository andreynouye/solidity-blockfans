// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILockeek is IERC20 {
    event Received(address indexed from, uint256 amount);
    event Recovered(
        address sender,
        address tokenAddress,
        uint256 amountOrTokenId
    );

    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool);

    function getHolders()
        external
        view
        returns (address[] memory, uint256[] memory);
}
