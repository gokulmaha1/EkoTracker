const db = require('../config/db');

exports.getProducts = async (req, res) => {
    try {
        const { last_updated } = req.query;
        let query = 'SELECT * FROM products';
        let params = [];

        if (last_updated) {
            query += ' WHERE updated_at > ?';
            params.push(last_updated);
        }

        const [products] = await db.execute(query, params);
        res.json(products);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.createProduct = async (req, res) => {
    const { name, sku, price, stock } = req.body;
    try {
        const [result] = await db.execute(
            'INSERT INTO products (name, sku, price, stock) VALUES (?, ?, ?, ?)',
            [name, sku, price, stock]
        );
        const [newProduct] = await db.execute('SELECT * FROM products WHERE id = ?', [result.insertId]);
        res.status(201).json(newProduct[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.updateProduct = async (req, res) => {
    const { id } = req.params;
    const { name, sku, price, stock, status } = req.body;
    try {
        await db.execute(
            'UPDATE products SET name = ?, sku = ?, price = ?, stock = ?, status = ? WHERE id = ?',
            [name, sku, price, stock, status, id]
        );
        const [updatedProduct] = await db.execute('SELECT * FROM products WHERE id = ?', [id]);
        res.json(updatedProduct[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};
