const db = require('../config/db');

exports.createOrder = async (req, res) => {
    const { visit_id, store_id, items, total_amount } = req.body;
    const user_id = req.user.id;

    if (!items || items.length === 0) {
        return res.status(400).json({ message: 'No items in order' });
    }

    const connection = await db.getConnection(); // Get a connection for transaction

    try {
        await connection.beginTransaction();

        // 1. Create Order
        const [orderResult] = await connection.execute(
            'INSERT INTO orders (visit_id, user_id, store_id, total_amount, status) VALUES (?, ?, ?, ?, ?)',
            [visit_id || null, user_id, store_id, total_amount, 'submitted']
        );
        const orderId = orderResult.insertId;

        // 2. Insert Order Items
        for (const item of items) {
            await connection.execute(
                'INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)',
                [orderId, item.product_id, item.quantity, item.price]
            );
        }

        await connection.commit();

        // Mock Notification
        console.log(`New Order Received! ID: ${orderId}, Amount: ${total_amount}`);

        res.status(201).json({ message: 'Order submitted successfully', orderId });

    } catch (error) {
        await connection.rollback();
        console.error(error);
        res.status(500).json({ message: 'Server error', error: error.message });
    } finally {
        connection.release();
    }
};

exports.getOrders = async (req, res) => {
    const { status, user_id } = req.query;
    try {
        let query = `
            SELECT o.*, s.name as store_name, u.name as user_name 
            FROM orders o
            JOIN stores s ON o.store_id = s.id
            JOIN users u ON o.user_id = u.id
        `;
        let params = [];
        let conditions = [];

        if (req.user.role !== 'admin') {
            conditions.push('o.user_id = ?');
            params.push(req.user.id);
        } else if (user_id) {
            conditions.push('o.user_id = ?');
            params.push(user_id);
        }

        if (status) {
            conditions.push('o.status = ?');
            params.push(status);
        }

        if (conditions.length > 0) {
            query += ' WHERE ' + conditions.join(' AND ');
        }

        query += ' ORDER BY o.created_at DESC';

        const [orders] = await db.execute(query, params);
        res.json(orders);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getOrderById = async (req, res) => {
    const { id } = req.params;
    try {
        const [orders] = await db.execute(
            'SELECT o.*, s.name as store_name, u.name as user_name FROM orders o JOIN stores s ON o.store_id = s.id JOIN users u ON o.user_id = u.id WHERE o.id = ?',
            [id]
        );

        if (orders.length === 0) {
            return res.status(404).json({ message: 'Order not found' });
        }

        const order = orders[0];

        // Check permission
        if (req.user.role !== 'admin' && req.user.id !== order.user_id) {
            return res.status(403).json({ message: 'Not authorized' });
        }

        const [items] = await db.execute(
            'SELECT oi.*, p.name as product_name FROM order_items oi JOIN products p ON oi.product_id = p.id WHERE oi.order_id = ?',
            [id]
        );

        res.json({ ...order, items });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.updateOrderStatus = async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;

    // Only admin can change status? Or maybe sales rep can cancel?
    // Let's assume Admin approves.

    const connection = await db.getConnection();

    try {
        await connection.beginTransaction();

        const [orders] = await connection.execute('SELECT * FROM orders WHERE id = ?', [id]);
        if (orders.length === 0) {
            connection.release();
            return res.status(404).json({ message: 'Order not found' });
        }
        const order = orders[0];

        if (status === 'approved' && order.status !== 'approved') {
            // Deduct stock
            const [items] = await connection.execute('SELECT * FROM order_items WHERE order_id = ?', [id]);
            for (const item of items) {
                // Check stock
                const [products] = await connection.execute('SELECT stock FROM products WHERE id = ?', [item.product_id]);
                if (products[0].stock < item.quantity) {
                    throw new Error(`Insufficient stock for product ID ${item.product_id}`);
                }

                await connection.execute('UPDATE products SET stock = stock - ? WHERE id = ?', [item.quantity, item.product_id]);

                // Log inventory change
                await connection.execute(
                    'INSERT INTO inventory_logs (product_id, change_type, quantity, notes) VALUES (?, ?, ?, ?)',
                    [item.product_id, 'order', -item.quantity, `Order #${id} Approved`]
                );
            }
        }

        await connection.execute('UPDATE orders SET status = ? WHERE id = ?', [status, id]);

        await connection.commit();

        // Check for Low Stock Alerts (Logic could go here)

        res.json({ message: `Order status updated to ${status}` });

    } catch (error) {
        await connection.rollback();
        console.error(error);
        res.status(400).json({ message: error.message });
    } finally {
        connection.release();
    }
};
