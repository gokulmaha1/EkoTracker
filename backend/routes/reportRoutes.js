const express = require('express');
const router = express.Router();
const { getPerformanceReport } = require('../controllers/reportController');
const { protect } = require('../middleware/authMiddleware');

router.get('/performance', protect, getPerformanceReport);

module.exports = router;
