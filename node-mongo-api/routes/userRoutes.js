const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { authenticate, requireAdmin } = require('../middleware/auth');

// Public routes
router.post('/login', userController.login);
router.post('/register', userController.registerUser); // Register route

// Routes requiring authentication
router.use(authenticate);

// Admin-only routes for managing users
router.get('/', requireAdmin, userController.getUsers);
router.put('/:id', requireAdmin, userController.updateUser);
router.delete('/:id', requireAdmin, userController.deleteUser);

module.exports = router;
