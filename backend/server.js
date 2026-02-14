const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const bodyParser = require('body-parser');
const authRoutes = require('./routes/authRoutes');
const storeRoutes = require('./routes/storeRoutes');
const productRoutes = require('./routes/productRoutes');
const orderRoutes = require('./routes/orderRoutes');
const inventoryRoutes = require('./routes/inventoryRoutes');
const invoiceRoutes = require('./routes/invoiceRoutes');
const locationRoutes = require('./routes/locationRoutes');
const path = require('path');

dotenv.config();

const app = express();

app.use(cors());
app.use(bodyParser.json());
app.use(express.static('public'));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.use('/api/auth', authRoutes);
app.use('/api/stores', storeRoutes);
app.use('/api/products', productRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/inventory', inventoryRoutes);
app.use('/api/invoices', invoiceRoutes);
app.use('/api/routes', routeRoutes);
app.use('/api/routes', routeRoutes);
app.use('/api/locations', locationRoutes);
app.use('/api/timeline', require('./routes/timelineRoutes'));

const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.send('API is running...');
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
