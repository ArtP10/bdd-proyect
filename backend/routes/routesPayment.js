const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');

// Rutas de Información (Lectura)
// POST porque enviamos { user_id } en el body
router.post('/quotas', paymentController.getPendingQuotas);
router.post('/history', paymentController.getPaymentHistory);

// Rutas de Transacción (Escritura)
router.post('/pay', paymentController.payQuota);
router.post('/refund', paymentController.requestRefund);

module.exports = router;