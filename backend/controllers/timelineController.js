const db = require('../config/db');

// Create a new timeline post
exports.createPost = async (req, res) => {
    const { store_id, type, description, gps_lat, gps_lng } = req.body;
    const user_id = req.user.id;
    const image_url = req.file ? req.file.filename : null;

    try {
        await db.execute(
            'INSERT INTO timeline_posts (user_id, store_id, type, description, image_url, gps_lat, gps_lng) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [
                user_id,
                store_id || null,
                type,
                description || null,
                image_url || null,
                gps_lat || null,
                gps_lng || null
            ]
        );
        res.status(201).json({ message: 'Post created successfully' });
    } catch (error) {
        console.error('Error creating timeline post:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Get timeline posts with filters
exports.getTimeline = async (req, res) => {
    const { user_id, store_id, date, type } = req.query;

    // Admin can see all, Sales can see their own? For now, let's allow seeing stream.
    // Ideally, logic should be: Admin sees all. Sales sees own + maybe team if allowed.
    // Let's implement filters.

    try {
        let query = `
            SELECT tp.*, u.name as user_name, s.name as store_name 
            FROM timeline_posts tp 
            JOIN users u ON tp.user_id = u.id 
            LEFT JOIN stores s ON tp.store_id = s.id 
        `;
        let params = [];
        let conditions = [];

        if (user_id) {
            conditions.push('tp.user_id = ?');
            params.push(user_id);
        }

        if (store_id) {
            conditions.push('tp.store_id = ?');
            params.push(store_id);
        }

        if (date) {
            conditions.push('DATE(tp.created_at) = ?');
            params.push(date);
        }

        if (type) {
            conditions.push('tp.type = ?');
            params.push(type);
        }

        if (conditions.length > 0) {
            query += ' WHERE ' + conditions.join(' AND ');
        }

        query += ' ORDER BY tp.created_at DESC LIMIT 50'; // Pagination TODO

        const [posts] = await db.execute(query, params);
        res.json(posts);
    } catch (error) {
        console.error('Error fetching timeline:', error);
        res.status(500).json({ message: 'Server error' });
    }
};
