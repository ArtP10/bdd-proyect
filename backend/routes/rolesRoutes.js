const express = require('express');
const router = express.Router();
const rolesController = require('../controllers/rolesController');

// --- RUTAS DE ROLES (CRUD BASE) ---
// URL: /api/roles
router.post('/roles', rolesController.crearRol);
router.get('/roles', rolesController.obtenerRoles);
router.put('/roles/:id', rolesController.actualizarRol);
router.delete('/roles/:id', rolesController.eliminarRol);

// --- RUTAS DE PRIVILEGIOS ---

// 1. Obtener lista maestra de privilegios
// URL: /api/privileges
router.get('/privileges', rolesController.obtenerTodosLosPrivilegios);

// 2. Obtener privilegios asignados a un rol
// URL: /api/rol-privileges/:id
router.get('/rol-privileges/:id', rolesController.obtenerPrivilegiosDeRol);

// 3. Asignar privilegio a rol
// URL: /api/rol-privileges
router.post('/rol-privileges', rolesController.asignarPrivilegio);

// 4. Revocar privilegio de rol
// URL: /api/rol-privileges
router.delete('/rol-privileges', rolesController.revocarPrivilegio);

module.exports = router;