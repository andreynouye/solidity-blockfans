// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./Interfaces/IBlockfans.sol";
import "./Interfaces/ICreators.sol";
import "./Interfaces/ICreatorsNFT.sol";
import "./Structures/Creator.sol";
import "./Structures/NFT.sol";
import "./Structures/NFTSource.sol";

contract CreatorsNFT is
    ERC721,
    ERC721URIStorage,
    ERC721Enumerable,
    Ownable,
    ICreatorsNFT
{
    IBlockfans private blockFansContract;
    ICreators private creatorsContract;

    address payable private blockFansAddress;

    uint256 public nextSourceId = 1;
    uint256 public nextNFTId = 1;

    mapping(uint256 => NFTSource.Detail) private nftSources;
    mapping(address => uint256[]) private creatorNFTs;

    mapping(uint256 => NFT.Detail) public nfts;

    constructor() ERC721("BlockfansNFT", "BFN") {
        blockFansAddress = payable(address(0));
        blockFansContract = IBlockfans(address(0));
        creatorsContract = ICreators(address(0));
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable {
        emit Received(msg.sender, msg.value);
    }

    // Descendent overrides
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage, IERC165)
        returns (bool)
    {
        return ERC721Enumerable.supportsInterface(interfaceId);
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    function _burn(
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721URIStorage) {
        ERC721URIStorage._burn(tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual override(ERC721, ERC721Enumerable) {
        ERC721Enumerable._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // End of descendent overrides

    function _formatTokenURI(
        address creator,
        string memory name,
        string memory description,
        string memory image,
        string memory external_url,
        NFTSource.MediaType mediaType
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"creator":"',
                                creator,
                                '"',
                                '"name":"',
                                name,
                                '"',
                                '"description":"',
                                description,
                                '"',
                                '"image":"',
                                image,
                                '"',
                                '"external_url":"',
                                external_url,
                                '"',
                                '"mediaType":"',
                                mediaType,
                                '"',
                                "}"
                            )
                        )
                    )
                )
            );
    }

    function _mintNFT(uint256 sourceId) internal returns (uint256) {
        NFTSource.Detail memory source = nftSources[sourceId];

        uint256 newNFTId = nextNFTId++;

        NFT.Detail memory newCard = NFT.Detail(
            newNFTId,
            source.creator,
            source.name,
            source.description,
            source.image,
            source.external_url,
            source.price,
            source.mediaType
        );

        nfts[newNFTId] = newCard;

        _mint(msg.sender, newNFTId);
        _setTokenURI(
            newNFTId,
            _formatTokenURI(
                newCard.creator,
                newCard.name,
                newCard.description,
                newCard.image,
                newCard.external_url,
                newCard.mediaType
            )
        );

        return newNFTId;
    }

    function _removeNFTSourceIdFromCreator(
        address creator,
        uint256 sourceId
    ) private {
        uint256 length = creatorNFTs[creator].length;
        for (uint i = 0; i < length; i++) {
            if (creatorNFTs[creator][i] == sourceId) {
                creatorNFTs[creator][i] = creatorNFTs[creator][length - 1];
                creatorNFTs[creator].pop();
                break;
            }
        }
    }

    function setBlockFans(address blockFans) external onlyOwner {
        blockFansAddress = payable(blockFans);
        blockFansContract = IBlockfans(blockFans);
    }

    function setCreators(address creatorsAddress) external onlyOwner {
        creatorsContract = ICreators(creatorsAddress);
    }

    function setNFTSource(
        string memory name,
        string memory description,
        string memory image,
        string memory external_url,
        uint256 price,
        uint256 units,
        NFTSource.MediaType mediaType
    ) public override {
        uint256 newSourceId = nextSourceId++;

        NFTSource.Detail memory newSource = NFTSource.Detail(
            newSourceId,
            msg.sender,
            name,
            description,
            image,
            external_url,
            price,
            units,
            mediaType,
            NFTSource.Status.Pending
        );

        nftSources[newSourceId] = newSource;
        creatorNFTs[msg.sender].push(newSourceId);
    }

    function getNFTsByCreator(
        address creator
    ) public view override returns (uint256[] memory) {
        return creatorNFTs[creator];
    }

    function getNFTDetailsByCreator(
        address creator
    ) public view override returns (NFTSource.Detail[] memory) {
        uint256[] memory nftIds = creatorNFTs[creator];
        NFTSource.Detail[] memory nftDetails = new NFTSource.Detail[](
            nftIds.length
        );

        for (uint i = 0; i < nftIds.length; i++) {
            nftDetails[i] = nftSources[nftIds[i]];
        }

        return nftDetails;
    }

    function deleteNFTSource(uint256 sourceId) public override {
        require(nftSources[sourceId].creator == msg.sender, "Not the creator");

        delete nftSources[sourceId];

        _removeNFTSourceIdFromCreator(msg.sender, sourceId);
    }

    function buyNFT(uint256 sourceId) external override {
        NFTSource.Detail memory source = nftSources[sourceId];

        console.log("price: ", source.price);
        console.log("blockFansAddress: ", blockFansAddress);

        require(
            blockFansContract.allowance(msg.sender, address(this)) >=
                source.price * 10 ** 18,
            "Allowance not set"
        );
        require(
            blockFansContract.transferFrom(
                msg.sender,
                blockFansAddress,
                source.price * 10 ** 18
            ),
            "Transfer failed"
        );

        uint256 newCardId = _mintNFT(sourceId);

        emit NFTTransferred(msg.sender, newCardId);
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
