const Web3 = require('web3');
const web3 = new Web3(process.env.HOST_WEB3);

const TitillionAddress = '0x045857BDEAE7C1c7252d611eB24eB55564198b4C';
const PrizePoolAddress = '0x5133BBdfCCa3Eb4F739D599ee4eC45cBCD0E16c5';
const GameCardUtilsAddress = '0x02df3a3F960393F5B349E40A599FEda91a7cc1A7';
const GameCardModelsAddress = '0x821f3361D454cc98b7555221A06Be563a7E2E0A6';
const GameCardAddress = '0x1780bCf4103D3F501463AD3414c7f4b654bb7aFd';
const SuperTrunfoAddress = '0xC66AB83418C20A65C3f8e83B3d11c8C3a6097b6F';
const SuperClanAddress = '0x8F4ec854Dd12F1fe79500a1f53D0cbB30f9b6134';
const MarketPlaceAddress = '0x71089Ba41e478702e1904692385Be3972B2cBf9e';

const SuperClanABI = require('../../Hardhat/artifacts/contracts/Interfaces/ISuperClan.sol/ISuperClan.json');
const superClanContract = new web3.eth.Contract(SuperClanABI.abi, SuperClanAddress);

const SuperTrunfoABI = require('../../Hardhat/artifacts/contracts/Interfaces/ISuperTrunfo.sol/ISuperTrunfo.json');
const superTrunfoContract = new web3.eth.Contract(SuperTrunfoABI.abi, SuperTrunfoAddress);

const GameCardABI = require('../../Hardhat/artifacts/contracts/Interfaces/IGameCard.sol/IGameCard.json');
const gameCardContract = new web3.eth.Contract(GameCardABI.abi, GameCardAddress);

const GameCardUtilsABI = require('../../Hardhat/artifacts/contracts/Interfaces/IGameCardUtils.sol/IGameCardUtils.json');
const gameCardUtilsContract = new web3.eth.Contract(GameCardUtilsABI.abi, GameCardUtilsAddress);

const GameCardModelsABI = require('../../Hardhat/artifacts/contracts/Interfaces/IGameCardModels.sol/IGameCardModels.json');
const gameCardModelsContract = new web3.eth.Contract(GameCardModelsABI.abi, GameCardModelsAddress);

const MarketPlaceABI = require('../../Hardhat/artifacts/contracts/Interfaces/IMarketPlace.sol/IMarketPlace.json');
const marketPlaceContract = new web3.eth.Contract(MarketPlaceABI.abi, MarketPlaceAddress);

module.exports = { web3, superClanContract, superTrunfoContract, gameCardContract, gameCardUtilsContract, gameCardModelsContract, marketPlaceContract };
