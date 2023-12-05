const express = require('express');
const router = express.Router();
const clansController = require('../controllers/clansController');

router.get('/list', clansController.getClans);

router.get('/:address/player', clansController.getPlayerClan);
router.get('/:address/detail', clansController.getClanDetails);

module.exports = router;
