const express = require('express');
const router = express.Router();
const controller = require('../controllers/reviewsController');

router.post('/create', controller.createReview);
router.get('/product/:type/:id', controller.getProductReviews);
router.get('/user/:userId', controller.getUserReviews);

module.exports = router;