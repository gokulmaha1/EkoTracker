const express = require('express');
const router = express.Router();
const { register, login, getMe, getAllUsers, resetPassword } = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

router.post('/register', register);
router.post('/login', login);
router.get('/me', protect, getMe);
router.get('/users', protect, getAllUsers);
router.put('/users/:id/reset-password', protect, resetPassword);

module.exports = router;
