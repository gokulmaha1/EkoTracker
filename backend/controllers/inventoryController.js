const db = require('../config/db');

exports.getInventoryLogs = async (req, res) => {
    const { product_id } = req.query;
    try {
        let query = 'SELECT il.*, p.name as product_name FROM inventory_logs il JOIN products p ON il.product_id = p.id';
        let params = [];

        if (product_id) {
            query += ' WHERE il.product_id = ?';
            params.push(product_id);
        }

        query += ' ORDER BY il.created_at DESC LIMIT 100';

        const [logs] = await db.execute(query, params);
        res.json(logs);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.adjustInventory = async (req, res) => {
    const { product_id, change_type, quantity, notes } = req.body;

    // change_type: restock, correction

    const connection = await db.getConnection();
    try {
        await connection.beginTransaction();

        // Update product stock
        await connection.execute(
            'UPDATE products SET stock = stock + ? WHERE id = ?',
            [quantity, product_id]
        );

        // Log
        await connection.execute(
            'INSERT INTO inventory_logs (product_id, change_type, quantity, notes) VALUES (?, ?, ?, ?)',
            [product_id, change_type, quantity, notes]
        );

        await connection.commit();

        res.json({ message: 'Inventory adjusted successfully' });
    } catch (error) {
        await connection.rollback();
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    } finally {
        connection.release();
    }
};
