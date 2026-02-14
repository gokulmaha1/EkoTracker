const express = require('express');
const router = express.Router();
const { logLocation, getLocations } = require('../controllers/locationController');
const { protect } = require('../middleware/authMiddleware');

router.post('/', protect, logLocation);
router.get('/', protect, getLocations);

module.exports = router;
