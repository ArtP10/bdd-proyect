const express = require('express');

const router = express.Router();

const cartController = require('../controllers/cartController');

router.post('/checkout', cartController.processCheckout);
router.post('/tickets', cartController.getMyTickets);
router.post('/scan', cartController.markTicketUsed);
router.post('/wishlist-items', cartController.getWishlistItemsForCart);
module.exports = router;