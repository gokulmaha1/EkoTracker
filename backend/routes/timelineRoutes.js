const express = require('express');
const router = express.Router();
const { createPost, getTimeline } = require('../controllers/timelineController');
const { protect } = require('../middleware/authMiddleware');
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/');
    },
    filename: function (req, file, cb) {
        cb(null, 'timeline-' + Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

router.get('/', protect, getTimeline);
router.post('/', protect, upload.single('image'), createPost);

module.exports = router;
