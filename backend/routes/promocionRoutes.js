const express = require('express');
const router = express.Router();
const promocionController = require('../controllers/promocionController');

router.post('/', promocionController.crearPromocion);
router.get('/', promocionController.obtenerPromociones);
router.put('/:id', promocionController.actualizarPromocion);
router.delete('/:id', promocionController.eliminarPromocion);
router.get('/listas-asignacion', promocionController.obtenerListasAsignacion);
router.post('/asignar', promocionController.asignarPromocion);
router.get('/:prom_codigo', promocionController.getPromocionData);

// 2. Ruta para realizar la búsqueda de elementos filtrados
router.get('/:prom_codigo/elementos', promocionController.buscarElementos);

// 3. Ruta para asignar o remover la promoción de un elemento
router.post('/:prom_codigo/gestion', promocionController.gestionarAsignacion);

module.exports = router;