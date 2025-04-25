const express = require('express');
const roleController = require('../controllers/roleController');
const router = express.Router();

router.get('/', roleController.getRoles);
router.post('/', roleController.createRole);
router.put('/:id', roleController.updateRole);
router.delete('/:id', roleController.deleteRole);

module.exports = router;
