const express = require('express');

const router = express.Router();

const cartController = require('../controllers/cartController');

router.post('/checkout', cartController.processCheckout);
router.post('/tickets', cartController.getMyTickets);

module.exports = router;