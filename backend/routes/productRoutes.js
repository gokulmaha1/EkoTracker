const express = require('express');
const router = express.Router();
const { getProducts, createProduct, updateProduct } = require('../controllers/productController');
const { protect, admin } = require('../middleware/authMiddleware');

router.get('/', protect, getProducts);
router.post('/', protect, admin, createProduct);
router.put('/:id', protect, admin, updateProduct);

module.exports = router;
