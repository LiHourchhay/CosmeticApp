const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { authenticate, requireAdmin } = require('../middleware/auth');

// public login route
router.post('/login', userController.login);

// Create user route without authentication
router.post('/', userController.createUser);  // No authentication middleware here

// All other routes require a valid JWT token
router.use(authenticate);

// Admin-only routes for managing users
router.get('/', requireAdmin, userController.getUsers);
router.put('/:id', requireAdmin, userController.updateUser);
router.delete('/:id', requireAdmin, userController.deleteUser);

module.exports = router;
