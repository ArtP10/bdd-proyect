
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

module.exports = router;