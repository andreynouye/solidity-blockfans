const { superTrunfoContract, gameCardContract } = require('../config/web3');

exports.getAvailablePlayers = async (req, res, next) => {
    try {
        const players = await superTrunfoContract.methods.getAvailablePlayers().call();
        const playerDetails = await Promise.all(
            players.map(player => superTrunfoContract.methods.getPlayerDetails(player).call())
        );
        res.send(playerDetails);
    } catch (error) {
        next(error);
    }
};

exports.getRankingPlayers = async (req, res, next) => {
    try {
        const players = await superTrunfoContract.methods.getAvailablePlayers().call();
        const playerDetails = await Promise.all(
            players.map(async (player, index) => {
                const details = await superTrunfoContract.methods.getPlayerDetails(player).call();
                return {
                    ...details,
                    walletAddress: players[index]
                };
            })
        );
        const formattedPlayerDetails = playerDetails.map(details => {
            const formattedAddress = details.walletAddress.slice(0, 5) + '...' + details.walletAddress.slice(-5);
            return {
                ...details,
                walletAddress: formattedAddress
            };
        });
        const sortedPlayerDetails = formattedPlayerDetails.sort((a, b) => Number(b.score) - Number(a.score));
        res.send(sortedPlayerDetails);
    } catch (error) {
        next(error);
    }
};

exports.getAllNFTsWithID = async (req, res, next) => {
    try {
        const { address } = req.params;
        const nfts = await gameCardContract.methods.getAllNFTsWithID(address).call();
        res.send(nfts);
    } catch (error) {
        next(error);
    }
};

exports.getPlayerDeck = async (req, res, next) => {
    try {
        const { address } = req.params;
        const deck = await superTrunfoContract.methods.getPlayerDeck(address).call();
        res.send(deck);
    } catch (error) {
        next(error);
    }
};

exports.getPlayerCards = async (req, res, next) => {
    try {
        const { address } = req.params;
        const nfts = await superTrunfoContract.methods.getPlayerCards(address).call();
        res.send(nfts);
    } catch (error) {
        next(error);
    }
};

exports.getPlayerLandCard = async (req, res, next) => {
    try {
        const { address } = req.params;
        const landCardId = await superTrunfoContract.methods.getPlayerLandCard(address).call();
        const landCardDetails = await gameCardContract.methods.getCardDetails(landCardId).call();
        res.send(landCardDetails);
    } catch (error) {
        next(error);
    }
};

exports.getPlayerDetails = async (req, res, next) => {
    try {
        const { address } = req.params;
        const playerDetails = await superTrunfoContract.methods.getPlayerDetails(address).call();
        res.send(playerDetails);
    } catch (error) {
        next(error);
    }
};


exports.getBattles = async (req, res, next) => {
    try {
        const { address } = req.params;
        const battles = await superTrunfoContract.methods.getBattles(address).call();
        res.send(battles);
    } catch (error) {
        next(error);
    }
};

