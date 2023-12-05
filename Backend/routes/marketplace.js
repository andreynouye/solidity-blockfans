const express = require('express');
const router = express.Router();
const marketPlaceController = require('../controllers/marketPlaceController');

router.get('/listed', marketPlaceController.getAllListedTokens);

module.exports = router;
