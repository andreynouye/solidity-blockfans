const express = require('express');
const router = express.Router();
const worldsController = require('../controllers/worldsController');

router.get('/scores', worldsController.getWorldScores);

module.exports = router;
