const express = require('express');
const router = express.Router();
const controller = require('../controllers/paq_turController'); 

// 1. Paquetes (CRUD)
router.post('/paquetes', controller.createPackage);
router.get('/paquetes', controller.getPackages);
router.put('/paquetes/:id', controller.updatePackage);
router.delete('/paquetes/:id', controller.deletePackage);
router.get('/paquetes/:id/detalles', controller.getPackageDetails);

// 2. Reglas
router.post('/reglas', controller.createRule);
router.get('/reglas', controller.getRules);
router.post('/asignar-regla', controller.assignRuleToPackage);
router.post('/paquetes/eliminar-elemento', controller.removePackageElement);


// 3. Gestión de Contenido (SEPARADO)

// A. Servicios Genéricos (Tours, Seguros, etc.)
router.get('/opciones/servicios', controller.getGenericServices);
router.post('/asignar/servicio-generico', controller.assignGenericService);

// B. Habitaciones (Reserva)
router.get('/opciones/habitaciones', controller.getRoomOptions);
router.post('/reservar/habitacion', controller.addRoomReservation);

// C. Restaurantes (Reserva)
router.get('/opciones/restaurantes', controller.getRestaurantOptions);
router.post('/reservar/restaurante', controller.addRestaurantReservation);

// D. Traslados
router.get('/traslados-disponibles', controller.getAvailableTransfers);
router.post('/asignar-traslado', controller.assignTransfer);

module.exports = router;