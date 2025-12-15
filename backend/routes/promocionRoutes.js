const express = require('express');
const router = express.Router();
const controller = require('../controllers/promocionController');

// CRUD
router.get('/', controller.obtenerPromociones);
router.post('/', controller.crearPromocion);
router.put('/:id', controller.actualizarPromocion);
router.delete('/:id', controller.eliminarPromocion);

// Builder y Detalles
router.get('/builder/:prom_codigo', controller.getPromocionData);
router.get('/builder/:prom_codigo/elementos', controller.buscarElementos);
router.get('/builder/hotel/:hotelId/habitaciones', controller.buscarHabitacionesHotel); // NUEVA RUTA
router.post('/builder/:prom_codigo/gestion', controller.gestionarAsignacion);

// ESTA ES LA RUTA QUE TE DABA 404
router.get('/:id/detalles', controller.getDetalleAsignaciones);

module.exports = router;