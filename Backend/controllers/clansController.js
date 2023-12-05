const { superClanContract } = require('../config/web3');

exports.getClans = async (req, res, next) => {
    try {
        const clans = await superClanContract.methods.getClans().call();
        res.send(clans);
    } catch (error) {
        next(error);
    }
};

exports.getPlayerClan = async (req, res, next) => {
    try {
        const { address } = req.params;
        const playerClan = await superClanContract.methods.getPlayerClan(address).call();
        res.send(playerClan);
    } catch (error) {
        next(error);
    }
};

exports.getClanDetails = async (req, res, next) => {
    try {
        const { address } = req.params;
        const clanDetails = await superClanContract.methods.getClanDetails(address).call();
        res.send(clanDetails);
    } catch (error) {
        next(error);
    }
};
