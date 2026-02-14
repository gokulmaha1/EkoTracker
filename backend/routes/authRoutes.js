const express = require('express');
const router = express.Router();
const { register, login, getMe, getAllUsers, resetPassword, updateUserTargets } = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

router.post('/register', register);
router.post('/login', login);
router.get('/me', protect, getMe);
router.get('/users', protect, getAllUsers);
router.put('/users/:id/reset-password', protect, resetPassword);
router.put('/users/:id/targets', protect, updateUserTargets);

module.exports = router;
