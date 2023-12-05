const express = require('express');
const router = express.Router();
const balanceController = require('../controllers/balanceController');

router.get('/:address', balanceController.getBalance);

module.exports = router;
