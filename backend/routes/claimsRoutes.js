const express = require('express');
const router = express.Router();
const controller = require('../controllers/claimsController');

router.post('/create', controller.createClaim);
router.get('/all', controller.getAllClaims);
router.post('/resolve', controller.resolveClaim);

module.exports = router;