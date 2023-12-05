const express = require('express');
const router = express.Router();
const playerController = require('../controllers/playerController');

router.get('/available', playerController.getAvailablePlayers);
router.get('/ranking', playerController.getRankingPlayers);

router.get('/:address/cards', playerController.getPlayerCards);
router.get('/:address/nfts', playerController.getAllNFTsWithID);
router.get('/:address/deck', playerController.getPlayerDeck);
router.get('/:address/landcard', playerController.getPlayerLandCard);
router.get('/:address/details', playerController.getPlayerDetails);
router.get('/:address/battles', playerController.getBattles);

module.exports = router;
