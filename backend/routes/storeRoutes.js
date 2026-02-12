const express = require('express');
const router = express.Router();
const { getStores, createStore, updateStore } = require('../controllers/storeController');
const { protect, admin } = require('../middleware/authMiddleware');

router.get('/', protect, getStores);
router.post('/', protect, admin, createStore); // Only admin can create stores? Or sales rep too? Let's restrict to admin for now, or allow sales rep.
router.put('/:id', protect, admin, updateStore); // Update store

module.exports = router;
