// backend/routes/reportRoutes.js
const express = require('express');
const router = express.Router();

const { 
    generarReportePaquetes, 
    generarReporteTopMillas,
    generarReporteAuditoria,
    generarReportePreferencias,
    generarReporteClientesMillas // <--- Importar
} = require('../controllers/reportController'); 

router.get('/paquetes', generarReportePaquetes);
router.get('/top-millas', generarReporteTopMillas);
router.get('/auditoria-reembolsos', generarReporteAuditoria);
router.get('/preferencias-vs-realidad', generarReportePreferencias);
router.get('/clientes-millas', generarReporteClientesMillas); // <--- NUEVA RUTA

module.exports = router;