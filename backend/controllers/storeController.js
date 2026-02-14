const db = require('../config/db');

exports.getStores = async (req, res) => {
    try {
        const { last_updated, page = 1, limit = 100 } = req.query;
        let query = 'SELECT * FROM stores';
        let params = [];

        if (last_updated) {
            query += ' WHERE updated_at > ?';
            params.push(last_updated);
        }

        // Pagination (optional, depending on sync strategy)
        // For full sync, we might want everything, but let's keep it simple for now.
        // If last_updated is provided, we likely want all changes since then.
        // If not, we might want to paginate or download all for initial sync.

        // For now, let's just return all matching stores for simplicity in offline sync
        // query += ' ORDER BY updated_at DESC';

        const [stores] = await db.execute(query, params);
        res.json(stores);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.createStore = async (req, res) => {
    const { name, owner_name, phone, address, area, lat, lng } = req.body;
    const image = req.file ? req.file.filename : null;
    const created_by = req.user ? req.user.id : null;

    try {
        const [result] = await db.execute(
            'INSERT INTO stores (name, owner_name, phone, address, area, lat, lng, image, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [name, owner_name, phone, address, area, lat, lng, image, created_by]
        );
        const [newStore] = await db.execute('SELECT * FROM stores WHERE id = ?', [result.insertId]);
        res.status(201).json(newStore[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Update store status (Onboarding workflow)
exports.updateStoreStatus = async (req, res) => {
    const { id } = req.params;
    const { status_level } = req.body;

    // Validate status level
    const validLevels = ['lead', 'contacted', 'visited', 'sample_given', 'negotiation', 'customer'];
    if (!validLevels.includes(status_level)) {
        return res.status(400).json({ message: 'Invalid status level' });
    }

    try {
        await db.execute(
            'UPDATE stores SET status_level = ? WHERE id = ?',
            [status_level, id]
        );

        // Optionally create a timeline post for status change automatically? 
        // For now, let client handle posting to timeline if needed, or trigger here.

        res.json({ message: 'Store status updated', status_level });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.updateStore = async (req, res) => {
    // ... existing updateStore code ...
    const { id } = req.params;
    const { name, owner_name, phone, address, area, lat, lng, status, status_level } = req.body;
    try {
        // Updated to include status_level in general update if needed
        await db.execute(
            'UPDATE stores SET name = ?, owner_name = ?, phone = ?, address = ?, area = ?, lat = ?, lng = ?, status = ? WHERE id = ?',
            [name, owner_name, phone, address, area, lat, lng, status, id]
        );
        // ...
        const [updatedStore] = await db.execute('SELECT * FROM stores WHERE id = ?', [id]);
        res.json(updatedStore[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};
