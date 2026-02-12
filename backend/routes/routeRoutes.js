const express = require('express');
const router = express.Router();
const { optimizeRoute } = require('../controllers/routeController');
const { protect } = require('../middleware/authMiddleware');

router.post('/optimize', protect, optimizeRoute);

module.exports = router;
