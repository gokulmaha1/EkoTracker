const db = require('./config/db');

async function updateSchema() {
    try {
        const connection = await db.getConnection();
        console.log('Connected to database.');

        // 1. Add image column to stores if not exists
        try {
            await connection.execute('ALTER TABLE stores ADD COLUMN image VARCHAR(255)');
            console.log('Added image column to stores table.');
        } catch (error) {
            if (error.code === 'ER_DUP_FIELDNAME') {
                console.log('image column already exists in stores table.');
            } else {
                console.error('Error adding image column:', error.message);
            }
        }

        // 2. Create location_logs table
        await connection.execute(`
            CREATE TABLE IF NOT EXISTS location_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                lat DECIMAL(10, 8) NOT NULL,
                lng DECIMAL(11, 8) NOT NULL,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id)
            )
        `);
        console.log('Creates location_logs table if it did not exist.');

        connection.release();
        console.log('Schema update complete.');
        process.exit(0);
    } catch (error) {
        console.error('Schema update failed:', error);
        process.exit(1);
    }
}

updateSchema();
