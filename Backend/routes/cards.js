const express = require('express');
const router = express.Router();
const playerController = require('../controllers/cardsController');

router.get('/models', playerController.getModels);
router.get('/minted', playerController.getOwnedNFTs);
router.get('/sale', playerController.getAllCardsForSale);

router.get('/:tokenId/owner', playerController.getCardOwner);
router.get('/:tokenId/details', playerController.getCardDetails);

module.exports = router;
