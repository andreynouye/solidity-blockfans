const { marketPlaceContract } = require('../config/web3');

exports.getAllListedTokens = async (req, res, next) => {
    try {
        const cards = await marketPlaceContract.methods.getAllListedTokens().call();
        res.send(cards);
    } catch (error) {
        next(error);
    }
};
