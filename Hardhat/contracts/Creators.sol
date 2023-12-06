// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Interfaces/IBlockfans.sol";
import "./Interfaces/ICreators.sol";
import "./Interfaces/ICreatorsNFT.sol";
import "./Structures/Creator.sol";

contract Creators is Ownable, ICreators {
    IBlockfans private blockFansContract;
    ICreatorsNFT private creatorsNFTContract;

    address[] private creatorAddresses;

    mapping(address => Creator.Detail) private creators;

    constructor() {
        blockFansContract = IBlockfans(address(0));
        creatorsNFTContract = ICreatorsNFT(address(0));
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable {
        emit Received(msg.sender, msg.value);
    }

    function _isCreatorAddressPresent(
        address creatorAddress
    ) private view returns (bool) {
        for (uint i = 0; i < creatorAddresses.length; i++) {
            if (creatorAddresses[i] == creatorAddress) {
                return true;
            }
        }
        return false;
    }

    function _removeCreatorAddress(address creatorAddress) private {
        uint256 length = creatorAddresses.length;
        for (uint256 i = 0; i < length; i++) {
            if (creatorAddresses[i] == creatorAddress) {
                creatorAddresses[i] = creatorAddresses[length - 1];
                creatorAddresses.pop();
                break;
            }
        }
    }

    function setBlockFans(address blockFansAddress) external onlyOwner {
        blockFansContract = IBlockfans(blockFansAddress);
    }

    function setCreatorsNFT(address creatorsNFTAddress) external onlyOwner {
        creatorsNFTContract = ICreatorsNFT(creatorsNFTAddress);
    }

    function addCreator(
        address creatorAddress,
        string memory name,
        string memory description,
        string memory location,
        Creator.Rating rating,
        Creator.Status status
    ) public onlyOwner {
        creators[creatorAddress] = Creator.Detail(
            name,
            description,
            location,
            rating,
            status
        );

        if (status == Creator.Status.Active) {
            creatorAddresses.push(creatorAddress);
        }
    }

    function changeCreatorStatus(
        address creatorAddress,
        Creator.Status newStatus
    ) public onlyOwner {
        require(
            creators[creatorAddress].status != Creator.Status(0),
            "Creator does not exist"
        );

        if (
            newStatus == Creator.Status.Active &&
            !_isCreatorAddressPresent(creatorAddress)
        ) {
            creatorAddresses.push(creatorAddress);
        } else if (
            newStatus != Creator.Status.Active &&
            _isCreatorAddressPresent(creatorAddress)
        ) {
            _removeCreatorAddress(creatorAddress);
        }

        creators[creatorAddress].status = newStatus;
    }

    function getCreators() public view override returns (address[] memory) {
        return creatorAddresses;
    }

    function isCreator(address user) public view returns (bool) {
        return creators[user].status == Creator.Status.Active;
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
