const { gameCardContract, gameCardModelsContract } = require('../config/web3');

exports.getAllCardsForSale = async (req, res, next) => {
    try {
        const cards = await gameCardContract.methods.getAllNFTs('0x0000000000000000000000000000000000000000').call();
        res.send(cards);
    } catch (error) {
        next(error);
    }
};

exports.getOwnedNFTs = async (req, res, next) => {
    try {
        const cards = await gameCardContract.methods.getOwnedNFTs().call();
        res.send(cards);
    } catch (error) {
        next(error);
    }
};

exports.getModels = async (req, res, next) => {
    try {
        const cards = await gameCardModelsContract.methods.getAllCardModels().call();
        res.send(cards);
    } catch (error) {
        next(error);
    }
};

exports.getCardOwner = async (req, res, next) => {
    try {
        const { tokenId } = req.params;
        const cards = await gameCardContract.methods.getCardOwner(tokenId).call();
        res.send(cards);
    } catch (error) {
        next(error);
    }
};

exports.getCardDetails = async (req, res, next) => {
    try {
        const { tokenId } = req.params;
        const cards = await gameCardContract.methods.getCardDetails(tokenId).call();
        res.send(cards);
    } catch (error) {
        next(error);
    }
};