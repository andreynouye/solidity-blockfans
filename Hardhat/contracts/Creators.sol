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

    mapping(address => Creator.Detail) internal creators;

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

    function setBlockFans(address blockFansAddress) external onlyOwner {
        blockFansContract = IBlockfans(blockFansAddress);
    }

    function setCreatorsNFT(address creatorsNFTAddress) external onlyOwner {
        creatorsNFTContract = ICreatorsNFT(creatorsNFTAddress);
    }

    /**
     * @dev Função para adicionar um novo criador.
     * @param creatorAddress Endereço do criador a ser adicionado.
     * @param status O status inicial do criador.
     */
    function addCreator(
        address creatorAddress,
        Creator.Status status
    ) public onlyOwner {
        creators[creatorAddress] = Creator.Detail(status);
    }

    /**
     * @dev Função para alterar o status de um criador existente.
     * @param creatorAddress Endereço do criador cujo status será alterado.
     * @param newStatus O novo status para o criador.
     */
    function changeCreatorStatus(
        address creatorAddress,
        Creator.Status newStatus
    ) public onlyOwner {
        require(
            creators[creatorAddress].status != Creator.Status(0),
            "Creator does not exist"
        );
        creators[creatorAddress].status = newStatus;
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
