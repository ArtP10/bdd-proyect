const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');

// Rutas de Información (Lectura)
// POST porque enviamos { user_id } en el body
router.post('/quotas', paymentController.getPendingQuotas);
router.post('/history', paymentController.getPaymentHistory);

// Rutas de Transacción (Escritura)
router.post('/pay-quota', paymentController.payQuota);
router.post('/refund', paymentController.requestRefund);
router.post('/preview-refund', paymentController.previewRefund);
router.post('/refunds-list', paymentController.getRefundsList);

router.post('/items', paymentController.getPurchaseItems)
module.exports = router;