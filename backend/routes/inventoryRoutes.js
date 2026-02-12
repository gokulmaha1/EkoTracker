const express = require('express');
const router = express.Router();
const { getInventoryLogs, adjustInventory } = require('../controllers/inventoryController');
const { protect, admin } = require('../middleware/authMiddleware');

router.get('/logs', protect, admin, getInventoryLogs);
router.post('/adjust', protect, admin, adjustInventory);

module.exports = router;
