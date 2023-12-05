const web3 = require('../config/web3');

exports.getBalance = async (req, res) => {
    try {
        const { address } = req.params;
        const balance = await web3.eth.getBalance(address);
        res.send({ balance });
    } catch (error) {
        res.status(500).send({ error: error.toString() });
    }
}
