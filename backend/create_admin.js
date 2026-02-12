const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');
const dotenv = require('dotenv');

dotenv.config();

const email = process.argv[2];
const password = process.argv[3];
const name = process.argv[4] || 'Admin';

if (!email || !password) {
    console.log('Usage: node create_admin.js <email> <password> [name]');
    process.exit(1);
}

async function createAdmin() {
    try {
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME
        });

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        const [result] = await connection.execute(
            'INSERT INTO users (name, email, password_hash, role) VALUES (?, ?, ?, ?)',
            [name, email, hashedPassword, 'admin']
        );

        console.log(`Admin user ${email} created successfully with ID: ${result.insertId}`);
        await connection.end();
    } catch (error) {
        console.error('Error creating admin user:', error.message);
        process.exit(1);
    }
}

createAdmin();
