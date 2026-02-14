const db = require('../config/db');

exports.logLocation = async (req, res) => {
    const { lat, lng, timestamp } = req.body;
    const user_id = req.user.id;

    if (!lat || !lng) {
        return res.status(400).json({ message: 'Latitude and Longitude are required' });
    }

    try {
        await db.execute(
            'INSERT INTO location_logs (user_id, lat, lng, timestamp) VALUES (?, ?, ?, ?)',
            [user_id, lat, lng, timestamp || new Date()]
        );
        res.status(201).json({ message: 'Location logged successfully' });
    } catch (error) {
        console.error('Error logging location:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getLocations = async (req, res) => {
    const { user_id, date } = req.query;

    // Only admin can view logs
    if (req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Not authorized' });
    }

    try {
        let query = 'SELECT * FROM location_logs';
        let params = [];
        let conditions = [];

        if (user_id) {
            conditions.push('user_id = ?');
            params.push(user_id);
        }

        if (date) {
            conditions.push('DATE(timestamp) = ?');
            params.push(date);
        }

        if (conditions.length > 0) {
            query += ' WHERE ' + conditions.join(' AND ');
        }

        query += ' ORDER BY timestamp DESC';

        const [logs] = await db.execute(query, params);
        res.json(logs);
    } catch (error) {
        console.error('Error fetching locations:', error);
        res.status(500).json({ message: 'Server error' });
    }
};
