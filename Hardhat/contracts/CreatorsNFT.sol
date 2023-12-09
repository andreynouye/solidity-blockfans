// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./Interfaces/ILockeek.sol";
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
    ILockeek private LockeekContract;
    ICreators private creatorsContract;

    address payable private LockeekAddress;

    uint256 public nextSourceId = 1;
    uint256 public nextNFTId = 1;

    mapping(uint256 => NFTSource.Detail) private nftSources;
    mapping(address => uint256[]) private creatorNFTs;
    mapping(address => uint256[]) private publicNFTs;

    mapping(uint256 => NFT.Detail) public nfts;
    mapping(uint256 => uint256) private soldUnitsPerSource;

    constructor() ERC721("LockeekNFT", "BFN") {
        LockeekAddress = payable(address(0));
        LockeekContract = ILockeek(address(0));
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

    function _removeNFTSourceIdFromPublic(
        address creator,
        uint256 sourceId
    ) private {
        uint256 length = publicNFTs[creator].length;
        for (uint i = 0; i < length; i++) {
            if (publicNFTs[creator][i] == sourceId) {
                publicNFTs[creator][i] = publicNFTs[creator][length - 1];
                publicNFTs[creator].pop();
                break;
            }
        }
    }

    function setLockeek(address Lockeek) external onlyOwner {
        LockeekAddress = payable(Lockeek);
        LockeekContract = ILockeek(Lockeek);
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
        require(creatorsContract.isCreator(msg.sender), "Not a creator");

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
            NFTSource.Status.Available
        );

        nftSources[newSourceId] = newSource;
        creatorNFTs[msg.sender].push(newSourceId);
        publicNFTs[msg.sender].push(newSourceId);
    }

    function getNFTsByCreator()
        public
        view
        override
        returns (uint256[] memory)
    {
        return creatorNFTs[msg.sender];
    }

    function getNFTDetailsByCreator()
        public
        view
        override
        returns (NFTSource.Detail[] memory)
    {
        uint256[] memory nftIds = creatorNFTs[msg.sender];
        NFTSource.Detail[] memory nftDetails = new NFTSource.Detail[](
            nftIds.length
        );

        for (uint i = 0; i < nftIds.length; i++) {
            nftDetails[i] = nftSources[nftIds[i]];
        }

        return nftDetails;
    }

    function getPublicNFTsByCreator(
        address creator
    ) public view override returns (uint256[] memory) {
        return publicNFTs[creator];
    }

    function getPublicNFTDetailsByCreator(
        address creator
    ) public view override returns (NFTSource.Detail[] memory) {
        uint256[] memory nftIds = publicNFTs[creator];
        NFTSource.Detail[] memory nftDetails = new NFTSource.Detail[](
            nftIds.length
        );

        for (uint i = 0; i < nftIds.length; i++) {
            nftDetails[i] = nftSources[nftIds[i]];
        }

        return nftDetails;
    }

    function getSoldUnitsPerSource(
        uint256 tokenId
    ) public view override returns (uint256) {
        return soldUnitsPerSource[tokenId];
    }

    function deleteNFTSource(uint256 sourceId) public override {
        require(nftSources[sourceId].creator == msg.sender, "Not the creator");
        require(
            nftSources[sourceId].status == NFTSource.Status.Pending ||
                nftSources[sourceId].status == NFTSource.Status.Available,
            "Not Available"
        );

        nftSources[sourceId].status = NFTSource.Status.Trashed;

        _removeNFTSourceIdFromPublic(msg.sender, sourceId);
    }

    function permanentDeleteNFTSource(uint256 sourceId) public override {
        require(nftSources[sourceId].creator == msg.sender, "Not the creator");
        require(
            nftSources[sourceId].status == NFTSource.Status.Trashed,
            "Not Available"
        );

        delete nftSources[sourceId];

        _removeNFTSourceIdFromCreator(msg.sender, sourceId);
        _removeNFTSourceIdFromPublic(msg.sender, sourceId);
    }

    function restoreNFTSource(uint256 sourceId) public override {
        require(nftSources[sourceId].creator == msg.sender, "Not the creator");

        nftSources[sourceId].status = NFTSource.Status.Available;

        publicNFTs[msg.sender].push(sourceId);
    }

    function buyNFT(uint256 sourceId) external override {
        NFTSource.Detail storage source = nftSources[sourceId];

        require(
            source.units == 0 || soldUnitsPerSource[sourceId] < source.units,
            "Sold Out"
        );
        require(source.status == NFTSource.Status.Available, "Not Available");

        require(
            LockeekContract.allowance(msg.sender, address(this)) >=
                source.price * 10 ** 18,
            "Allowance not set"
        );
        require(
            LockeekContract.transferFrom(
                msg.sender,
                LockeekAddress,
                source.price * 10 ** 18
            ),
            "Transfer failed"
        );

        uint256 newCardId = _mintNFT(sourceId);

        soldUnitsPerSource[sourceId]++;

        if (source.units != 0 && soldUnitsPerSource[sourceId] >= source.units) {
            source.status = NFTSource.Status.SoldOut;
        }

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
