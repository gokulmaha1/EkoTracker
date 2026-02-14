const mysql = require('mysql2/promise');
require('dotenv').config();

async function test() {
    const config = {
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME || 'eko_tracker',
        port: process.env.DB_PORT || 3306 // Default to 3306 if validation fails
    };
    console.log(`Testing connection to ${config.host}:${config.port}...`);
    try {
        const connection = await mysql.createConnection(config);
        console.log('Connected successfully!');
        await connection.end();
        process.exit(0);
    } catch (e) {
        console.error('Connection failed:', e);
        process.exit(1);
    }
}
test();
