const express = require('express');
const router = express.Router();
const { getStores, createStore, updateStore, updateStoreStatus } = require('../controllers/storeController');
const { protect, admin } = require('../middleware/authMiddleware');

const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/');
    },
    filename: function (req, file, cb) {
        cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

router.get('/', protect, getStores);
router.post('/', protect, upload.single('image'), createStore);
router.put('/:id', protect, admin, upload.single('image'), updateStore);
router.put('/:id/status', protect, updateStoreStatus); // Allow sales reps to update status

module.exports = router;
