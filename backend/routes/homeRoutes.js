const express = require('express');

const router = express.Router();

const homeController = require('../controllers/homeController');

router.get('/get-home-data', homeController.getHomeData);
router.post('/search', homeController.searchResources)


module.exports = router;



