const express = require('express');
const router = express.Router();
const wishlistController = require('../controllers/wishlistController');

// Definimos la URL: /api/wishlist/:userId
router.get('/:userId', wishlistController.getWishlist);

router.post('/add', wishlistController.addToWishlist);

router.delete('/remove', wishlistController.removeFromWishlist);

module.exports = router;