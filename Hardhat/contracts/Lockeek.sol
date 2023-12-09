// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./Interfaces/ILockeek.sol";
import "./Interfaces/ICreators.sol";

contract Lockeek is ERC20, Ownable, ILockeek {
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private holders;

    ICreators private creators;

    address payable public companyAddress;
    uint256 public companyPercentage;

    constructor() ERC20("Lockeek", "KEEK") {
        _mint(msg.sender, 1 * 10 ** 12 * 10 ** 18);
        companyPercentage = 5;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable {
        emit Received(msg.sender, msg.value);
    }

    function setCompanyAddress(address _companyAddress) public onlyOwner {
        companyAddress = payable(_companyAddress);
    }

    function setCompanyTax(uint256 _companyTax) public onlyOwner {
        companyPercentage = _companyTax;
    }

    function getHolders()
        public
        view
        override
        returns (address[] memory, uint256[] memory)
    {
        uint256 holdersCount = holders.length();
        address[] memory holderAddresses = new address[](holdersCount);
        uint256[] memory holderBalances = new uint256[](holdersCount);

        for (uint256 i = 0; i < holdersCount; i++) {
            address holderAddress = holders.at(i);
            holderAddresses[i] = holderAddress;
            holderBalances[i] = balanceOf(holderAddress);
        }

        return (holderAddresses, holderBalances);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override(ERC20, ILockeek) returns (bool) {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        if (balanceOf(recipient) == 0 && amount > 0) {
            holders.add(recipient);
        }

        uint256 senderBalance = balanceOf(msg.sender);
        if (senderBalance - amount == 0) {
            holders.remove(msg.sender);
        }

        _transfer(msg.sender, recipient, amount);

        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override(ERC20, ILockeek) returns (bool) {
        require(
            allowance(sender, msg.sender) >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, msg.sender, allowance(sender, msg.sender) - amount);

        uint256 companyTax = (amount * companyPercentage) / 100;
        uint256 amountAfterTax = amount - companyTax;

        require(balanceOf(sender) >= amount, "Insufficient balance");

        if (balanceOf(recipient) == 0 && amount > 0) {
            holders.add(recipient);
        }

        uint256 senderBalance = balanceOf(sender);
        if (senderBalance - amount == 0) {
            holders.remove(sender);
        }

        _transfer(sender, companyAddress, companyTax);
        _transfer(sender, recipient, amountAfterTax);

        return true;
    }

    function withdraw(
        address tokenAddress,
        uint256 amountOrTokenId
    ) external onlyOwner {
        if (tokenAddress == address(0)) {
            require(
                address(this).balance >= amountOrTokenId,
                "Insufficient ETH balance in contract"
            );
            payable(owner()).transfer(amountOrTokenId);
            emit Recovered(msg.sender, tokenAddress, amountOrTokenId);
        } else {
            try IERC20(tokenAddress).transfer(owner(), amountOrTokenId) {
                emit Recovered(msg.sender, tokenAddress, amountOrTokenId);
                return;
            } catch {}

            try
                IERC721(tokenAddress).safeTransferFrom(
                    address(this),
                    owner(),
                    amountOrTokenId
                )
            {
                emit Recovered(msg.sender, tokenAddress, amountOrTokenId);
                return;
            } catch {}

            revert("Token type not supported or insufficient balance");
        }
    }
}
