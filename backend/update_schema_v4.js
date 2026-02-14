require('dotenv').config();
const db = require('./config/db');

async function updateSchema() {
    try {
        console.log(`Connecting to ${process.env.DB_HOST}...`);
        const connection = await db.getConnection();
        console.log('Connected to database.');

        // Update users table
        try {
            await connection.execute("ALTER TABLE users ADD COLUMN monthly_sales_target DECIMAL(10, 2) DEFAULT 400000.00");
            console.log('Added monthly_sales_target to users.');
        } catch (e) {
            if (e.code !== 'ER_DUP_FIELDNAME') console.error('Error adding monthly_sales_target:', e.message);
        }

        try {
            await connection.execute("ALTER TABLE users ADD COLUMN monthly_new_customer_target INT DEFAULT 20");
            console.log('Added monthly_new_customer_target to users.');
        } catch (e) {
            if (e.code !== 'ER_DUP_FIELDNAME') console.error('Error adding monthly_new_customer_target:', e.message);
        }

        // Update stores table
        try {
            await connection.execute("ALTER TABLE stores ADD COLUMN created_by INT");
            console.log('Added created_by to stores.');
            // Optional: Add FK if desired, but might fail if existing data has no created_by
            // await connection.execute("ALTER TABLE stores ADD FOREIGN KEY (created_by) REFERENCES users(id)");
        } catch (e) {
            if (e.code !== 'ER_DUP_FIELDNAME') console.error('Error adding created_by:', e.message);
        }

        connection.release();
        console.log('Schema update complete.');
        process.exit(0);
    } catch (error) {
        console.error('Schema update failed:', error);
        process.exit(1);
    }
}

updateSchema();
