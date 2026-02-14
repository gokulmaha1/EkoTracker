const db = require('../config/db');

exports.getPerformanceReport = async (req, res) => {
    try {
        const { year, month } = req.query;
        const currentYear = year || new Date().getFullYear();
        const currentMonth = month || new Date().getMonth() + 1; // 1-12

        // Determine users to fetch
        let usersQuery = 'SELECT id, name, monthly_sales_target, monthly_new_customer_target FROM users';
        let usersParams = [];
        if (req.user.role !== 'admin') {
            usersQuery += ' WHERE id = ?';
            usersParams.push(req.user.id);
        }

        const [users] = await db.execute(usersQuery, usersParams);

        const report = [];

        for (const user of users) {
            // 1. Calculate Actual Sales (Total of approved/submitted orders in month)
            // Using 'created_at' for simplicity. 'status' should probably be check too (exclude cancelled).
            const [salesResult] = await db.execute(`
                SELECT SUM(total_amount) as total 
                FROM orders 
                WHERE user_id = ? 
                AND status != 'cancelled'
                AND YEAR(created_at) = ? 
                AND MONTH(created_at) = ?
             `, [user.id, currentYear, currentMonth]);

            const actualSales = salesResult[0].total || 0;

            // 2. Calculate New Customers (Stores created by user in month)
            // Assuming 'created_by' is populated
            const [storesResult] = await db.execute(`
                SELECT COUNT(*) as count 
                FROM stores 
                WHERE created_by = ? 
                AND YEAR(created_at) = ? 
                AND MONTH(created_at) = ?
             `, [user.id, currentYear, currentMonth]);

            const newCustomers = storesResult[0].count || 0;

            report.push({
                user_id: user.id,
                name: user.name,
                sales_target: parseFloat(user.monthly_sales_target || 0),
                actual_sales: parseFloat(actualSales),
                new_customer_target: parseInt(user.monthly_new_customer_target || 0),
                actual_new_customers: parseInt(newCustomers),
                month: parseInt(currentMonth),
                year: parseInt(currentYear)
            });
        }

        res.json(report);

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};
