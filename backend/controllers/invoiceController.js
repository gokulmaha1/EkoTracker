const db = require('../config/db');

exports.createInvoice = async (req, res) => {
    const { order_id } = req.body;

    try {
        // Check if invoice already exists
        const [existing] = await db.execute('SELECT * FROM invoices WHERE order_id = ?', [order_id]);
        if (existing.length > 0) {
            return res.status(400).json({ message: 'Invoice already exists for this order' });
        }

        // Get Order details
        const [orders] = await db.execute('SELECT * FROM orders WHERE id = ?', [order_id]);
        if (orders.length === 0) {
            return res.status(404).json({ message: 'Order not found' });
        }
        const order = orders[0];

        if (order.status !== 'approved' && order.status !== 'packed' && order.status !== 'delivered') {
            return res.status(400).json({ message: 'Order must be approved to generate invoice' });
        }

        const invoiceNumber = `INV-${Date.now()}`;

        await db.execute(
            'INSERT INTO invoices (order_id, invoice_number, amount, status) VALUES (?, ?, ?, ?)',
            [order_id, invoiceNumber, order.total_amount, 'pending']
        );

        // Generate PDF (Mock)
        // In a real app, we would generate a PDF buffer here or return a URL.

        res.status(201).json({ message: 'Invoice generated', invoiceNumber });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getInvoices = async (req, res) => {
    try {
        const [invoices] = await db.execute(
            'SELECT i.*, o.user_id, s.name as store_name FROM invoices i JOIN orders o ON i.order_id = o.id JOIN stores s ON o.store_id = s.id ORDER BY i.created_at DESC'
        );
        res.json(invoices);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};
