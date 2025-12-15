const express = require('express');
const router = express.Router();
const controller = require('../controllers/rolController');

router.get('/', controller.getRoles);
router.post('/', controller.createRol);
router.put('/:id', controller.updateRol);
router.delete('/:id', controller.deleteRol);

module.exports = router;