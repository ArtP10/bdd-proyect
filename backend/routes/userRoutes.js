
const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');


router.post('/login', userController.loginUser);
router.post('/register', userController.registerClient);
router.post('/travelers/list', userController.getTravelers);
router.post('/travelers/create', userController.createTraveler);
router.post('/travelers/add-document', userController.addDocument);
router.post('/travelers/update-status', userController.updateCivilStatus);
router.post('/travelers/details', userController.getTravelerDetails);
router.get('/nationalities/list', userController.getNationalities);
router.get('/nationalities/list', userController.getNationalities);
router.get('/civil-statuses/list', userController.getCivilStatuses);
router.post('/travelers/delete-document', userController.deleteDocument);
router.get('/locations/list', userController.getLocations);
router.get('/providers/list', userController.getProviders);
router.post('/providers/create', userController.createProvider);
router.post('/providers/fleet/list', userController.getFleet);
router.post('/providers/fleet/create', userController.createPlane);
router.post('/providers/fleet/update', userController.updatePlane);
router.post('/providers/fleet/delete', userController.deletePlane);
router.post('/providers/routes/terminals', userController.getCompatibleTerminals);
router.post('/providers/routes/list', userController.getRoutes);
router.post('/providers/routes/create', userController.createRoute);
router.post('/providers/routes/delete', userController.deleteRoute);
router.post('/providers/travels/list', userController.getTravels);
router.post('/providers/routes/update', userController.updateRoute);
router.post('/providers/travels/create', userController.createTravel);
router.post('/providers/travels/update', userController.updateTravel);
router.post('/my-tickets', userController.getMyTickets);

module.exports = router;