const express = require('express');
const router = express.Router();
const rolesController = require('../controllers/rolesController');

router.post('/', rolesController.crearRol);
router.get('/', rolesController.obtenerRoles);
router.put('/:id', rolesController.actualizarRol);
router.delete('/:id', rolesController.eliminarRol);

module.exports = router;
