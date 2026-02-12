const express = require('express');
const router = express.Router();
const { createInvoice, getInvoices } = require('../controllers/invoiceController');
const { protect, admin } = require('../middleware/authMiddleware');

router.post('/', protect, admin, createInvoice);
router.get('/', protect, admin, getInvoices); // Sales rep might need to see invoices too

module.exports = router;
