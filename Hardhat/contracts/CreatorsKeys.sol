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
import "./Interfaces/ICreatorsKeys.sol";
import "./Structures/Creator.sol";
import "./Structures/Key.sol";
import "./Structures/KeySource.sol";

contract CreatorsKeys is
    ERC721,
    ERC721URIStorage,
    ERC721Enumerable,
    Ownable,
    ICreatorsKeys
{
    ILockeek private LockeekContract;
    ICreators private creatorsContract;

    address payable private LockeekAddress;

    uint256 public nextSourceId = 1;
    uint256 public nextKeyId = 1;

    mapping(uint256 => KeySource.Detail) private keySources;
    mapping(address => uint256[]) private creatorKeys;
    mapping(address => uint256[]) private publicKeys;

    mapping(uint256 => Key.Detail) public keys;
    mapping(uint256 => uint256) private soldUnitsPerSource;

    constructor() ERC721("LockeekKey", "BFN") {
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
        uint256 duration,
        uint256 price
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
                                '"duration":"',
                                duration,
                                '"',
                                '"price":"',
                                price,
                                '"',
                                "}"
                            )
                        )
                    )
                )
            );
    }

    function _mintKey(uint256 sourceId) internal returns (uint256) {
        KeySource.Detail memory source = keySources[sourceId];

        uint256 newKeyId = nextKeyId++;

        Key.Detail memory newCard = Key.Detail(
            newKeyId,
            source.creator,
            source.name,
            source.description,
            source.image,
            source.external_url,
            source.duration,
            source.price
        );

        keys[newKeyId] = newCard;

        _mint(msg.sender, newKeyId);
        _setTokenURI(
            newKeyId,
            _formatTokenURI(
                newCard.creator,
                newCard.name,
                newCard.description,
                newCard.image,
                newCard.external_url,
                newCard.duration,
                newCard.price
            )
        );

        return newKeyId;
    }

    function _removeKeySourceIdFromCreator(
        address creator,
        uint256 sourceId
    ) private {
        uint256 length = creatorKeys[creator].length;
        for (uint i = 0; i < length; i++) {
            if (creatorKeys[creator][i] == sourceId) {
                creatorKeys[creator][i] = creatorKeys[creator][length - 1];
                creatorKeys[creator].pop();
                break;
            }
        }
    }

    function _removeKeySourceIdFromPublic(
        address creator,
        uint256 sourceId
    ) private {
        uint256 length = publicKeys[creator].length;
        for (uint i = 0; i < length; i++) {
            if (publicKeys[creator][i] == sourceId) {
                publicKeys[creator][i] = publicKeys[creator][length - 1];
                publicKeys[creator].pop();
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

    function setKeySource(
        string memory name,
        string memory description,
        string memory image,
        string memory external_url,
        uint256 duration,
        uint256 price,
        uint256 units
    ) public override {
        require(creatorsContract.isCreator(msg.sender), "Not a creator");

        uint256 newSourceId = nextSourceId++;

        KeySource.Detail memory newSource = KeySource.Detail(
            newSourceId,
            msg.sender,
            name,
            description,
            image,
            external_url,
            duration,
            price,
            units,
            KeySource.Status.Available
        );

        keySources[newSourceId] = newSource;
        creatorKeys[msg.sender].push(newSourceId);
        publicKeys[msg.sender].push(newSourceId);
    }

    function getKeysByCreator()
        public
        view
        override
        returns (uint256[] memory)
    {
        return creatorKeys[msg.sender];
    }

    function getKeyDetailsByCreator()
        public
        view
        override
        returns (KeySource.Detail[] memory)
    {
        uint256[] memory keyIds = creatorKeys[msg.sender];
        KeySource.Detail[] memory keyDetails = new KeySource.Detail[](
            keyIds.length
        );

        for (uint i = 0; i < keyIds.length; i++) {
            keyDetails[i] = keySources[keyIds[i]];
        }

        return keyDetails;
    }

    function getPublicKeysByCreator(
        address creator
    ) public view override returns (uint256[] memory) {
        return publicKeys[creator];
    }

    function getPublicKeyDetailsByCreator(
        address creator
    ) public view override returns (KeySource.Detail[] memory) {
        uint256[] memory keyIds = publicKeys[creator];
        KeySource.Detail[] memory keyDetails = new KeySource.Detail[](
            keyIds.length
        );

        for (uint i = 0; i < keyIds.length; i++) {
            keyDetails[i] = keySources[keyIds[i]];
        }

        return keyDetails;
    }

    function getSoldUnitsPerSource(
        uint256 tokenId
    ) public view override returns (uint256) {
        return soldUnitsPerSource[tokenId];
    }

    function deleteKeySource(uint256 sourceId) public override {
        require(keySources[sourceId].creator == msg.sender, "Not the creator");
        require(
            keySources[sourceId].status == KeySource.Status.Pending ||
                keySources[sourceId].status == KeySource.Status.Available,
            "Not Available"
        );

        keySources[sourceId].status = KeySource.Status.Trashed;

        _removeKeySourceIdFromPublic(msg.sender, sourceId);
    }

    function permanentDeleteKeySource(uint256 sourceId) public override {
        require(keySources[sourceId].creator == msg.sender, "Not the creator");
        require(
            keySources[sourceId].status == KeySource.Status.Trashed,
            "Not Available"
        );

        delete keySources[sourceId];

        _removeKeySourceIdFromCreator(msg.sender, sourceId);
        _removeKeySourceIdFromPublic(msg.sender, sourceId);
    }

    function restoreKeySource(uint256 sourceId) public override {
        require(keySources[sourceId].creator == msg.sender, "Not the creator");

        keySources[sourceId].status = KeySource.Status.Available;

        publicKeys[msg.sender].push(sourceId);
    }

    function buyKey(uint256 sourceId) external override {
        KeySource.Detail storage source = keySources[sourceId];

        require(
            source.units == 0 || soldUnitsPerSource[sourceId] < source.units,
            "Sold Out"
        );
        require(source.status == KeySource.Status.Available, "Not Available");

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

        uint256 newCardId = _mintKey(sourceId);

        soldUnitsPerSource[sourceId]++;

        if (source.units != 0 && soldUnitsPerSource[sourceId] >= source.units) {
            source.status = KeySource.Status.SoldOut;
        }

        emit KeyTransferred(msg.sender, newCardId);
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
