const db = require('./config/db');

async function updateSchema() {
    try {
        const connection = await db.getConnection();
        console.log('Connected to database.');

        // 1. Update stores table
        try {
            await connection.execute("ALTER TABLE stores ADD COLUMN status_level ENUM('lead', 'contacted', 'visited', 'sample_given', 'negotiation', 'customer') DEFAULT 'lead'");
            console.log('Added status_level to stores.');
        } catch (e) {
            if (e.code !== 'ER_DUP_FIELDNAME') console.error('Error adding status_level:', e.message);
        }

        try {
            await connection.execute("ALTER TABLE stores ADD COLUMN credit_limit DECIMAL(10, 2) DEFAULT 0.00");
            console.log('Added credit_limit to stores.');
        } catch (e) {
            if (e.code !== 'ER_DUP_FIELDNAME') console.error('Error adding credit_limit:', e.message);
        }

        try {
            await connection.execute("ALTER TABLE stores ADD COLUMN price_list_id INT DEFAULT NULL"); // For future use
            console.log('Added price_list_id to stores.');
        } catch (e) {
            if (e.code !== 'ER_DUP_FIELDNAME') console.error('Error adding price_list_id:', e.message);
        }

        // 2. Create timeline_posts table
        await connection.execute(`
            CREATE TABLE IF NOT EXISTS timeline_posts (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                store_id INT, 
                type ENUM('visit', 'order', 'lead', 'follow_up', 'status_change', 'general') NOT NULL,
                description TEXT,
                image_url VARCHAR(255),
                gps_lat DECIMAL(10, 8),
                gps_lng DECIMAL(11, 8),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id),
                FOREIGN KEY (store_id) REFERENCES stores(id)
            )
        `);
        console.log('Created timeline_posts table.');

        connection.release();
        console.log('Schema update complete.');
        process.exit(0);
    } catch (error) {
        console.error('Schema update failed:', error);
        process.exit(1);
    }
}

updateSchema();
