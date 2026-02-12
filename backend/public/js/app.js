const API_URL = '/api';

// Auth
function login(email, password) {
    return fetch(`${API_URL}/auth/login`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ email, password })
    }).then(res => {
        if (!res.ok) throw new Error('Login failed');
        return res.json();
    });
}

function logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    window.location.href = 'index.html';
}

function checkAuth() {
    const token = localStorage.getItem('token');
    if (!token) {
        window.location.href = 'index.html';
    }
    return token;
}

// UI Helpers
const loginForm = document.getElementById('loginForm');
if (loginForm) {
    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;
        const alertBox = document.getElementById('alertMessage');

        try {
            const data = await login(email, password);
            if (data.user.role !== 'admin') {
                throw new Error('Access denied. Admin only.');
            }
            localStorage.setItem('token', data.token);
            localStorage.setItem('user', JSON.stringify(data.user));
            window.location.href = 'dashboard.html';
        } catch (error) {
            alertBox.textContent = error.message || 'Invalid credentials';
            alertBox.classList.remove('d-none');
        }
    });
}

// Dashboard Logic
async function fetchStats() {
    const token = checkAuth();
    // Use headers
    const headers = { 'Authorization': `Bearer ${token}` };

    // Mock stats for now or fetch if endpoints exist
    // Let's implement dashboard stats endpoint later. 
    // For now, fetch lists and count.

    try {
        const [stores, orders, products] = await Promise.all([
            fetch(`${API_URL}/stores`, { headers }).then(res => res.json()),
            fetch(`${API_URL}/orders`, { headers }).then(res => res.json()),
            fetch(`${API_URL}/products`, { headers }).then(res => res.json())
        ]);

        document.getElementById('totalStores').textContent = stores.length;
        document.getElementById('totalOrders').textContent = orders.length;
        document.getElementById('totalProducts').textContent = products.length;

        // Recent Orders Table
        const tbody = document.getElementById('ordersTableBody');
        tbody.innerHTML = orders.slice(0, 5).map(order => `
            <tr>
                <td>${order.id}</td>
                <td>${order.store_name}</td>
                <td>${order.user_name}</td>
                <td>₹${order.total_amount}</td>
                <td><span class="badge bg-${getStatusColor(order.status)}">${order.status}</span></td>
            </tr>
        `).join('');

    } catch (e) {
        console.error(e);
        if (e.message.includes('401') || e.message.includes('Forbidden')) logout();
    }
}

function getStatusColor(status) {
    switch (status) {
        case 'submitted': return 'warning';
        case 'approved': return 'info';
        case 'packed': return 'primary';
        case 'delivered': return 'success';
        case 'cancelled': return 'danger';
        default: return 'secondary';
    }
}

if (window.location.pathname.includes('dashboard.html')) {
    checkAuth();
    fetchStats();
}

// Master Data Logic
async function fetchMasterData() {
    const token = checkAuth();
    const headers = { 'Authorization': `Bearer ${token}` };

    try {
        const [stores, products] = await Promise.all([
            fetch(`${API_URL}/stores`, { headers }).then(res => res.json()),
            fetch(`${API_URL}/products`, { headers }).then(res => res.json())
        ]);

        const storesTable = document.getElementById('storesTableBody');
        storesTable.innerHTML = stores.map(store => `
            <tr>
                <td>${store.id}</td>
                <td>${store.name}</td>
                <td>${store.area || '-'}</td>
                <td>${store.phone || '-'}</td>
                <td>
                    <button class="btn btn-sm btn-info">Edit</button>
                    <button class="btn btn-sm btn-danger">Delete</button>
                </td>
            </tr>
        `).join('');

        const productsTable = document.getElementById('productsTableBody');
        productsTable.innerHTML = products.map(prod => `
            <tr>
                <td>${prod.id}</td>
                <td>${prod.name}</td>
                <td>${prod.sku || '-'}</td>
                <td>₹${prod.price}</td>
                <td>${prod.stock}</td>
                <td>
                    <button class="btn btn-sm btn-info">Edit</button>
                </td>
            </tr>
        `).join('');

    } catch (e) {
        console.error(e);
    }
}

// Store Modals
let storeModal;
function showAddStoreModal() {
    storeModal = new bootstrap.Modal(document.getElementById('addStoreModal'));
    storeModal.show();
}

document.getElementById('addStoreForm')?.addEventListener('submit', async (e) => {
    e.preventDefault();
    const token = checkAuth();
    const storeData = {
        name: document.getElementById('storeName').value,
        owner_name: document.getElementById('storeOwner').value,
        phone: document.getElementById('storePhone').value,
        area: document.getElementById('storeArea').value,
        address: document.getElementById('storeAddress').value,
        lat: 0,
        lng: 0
    };

    try {
        const res = await fetch(`${API_URL}/stores`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(storeData)
        });
        if (!res.ok) throw new Error('Failed to create store');
        storeModal.hide();
        fetchMasterData(); // Refresh
        e.target.reset();
    } catch (error) {
        alert(error.message);
    }
});

// Product Modals
let productModal;
function showAddProductModal() {
    productModal = new bootstrap.Modal(document.getElementById('addProductModal'));
    productModal.show();
}

document.getElementById('addProductForm')?.addEventListener('submit', async (e) => {
    e.preventDefault();
    const token = checkAuth();
    const prodData = {
        name: document.getElementById('prodName').value,
        sku: document.getElementById('prodSku').value,
        price: document.getElementById('prodPrice').value,
        stock: document.getElementById('prodStock').value
    };

    try {
        const res = await fetch(`${API_URL}/products`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(prodData)
        });
        if (!res.ok) throw new Error('Failed to create product');
        productModal.hide();
        fetchMasterData();
        e.target.reset();
    } catch (error) {
        alert(error.message);
    }
});

if (window.location.pathname.includes('master_data.html')) {
    checkAuth();
    fetchMasterData();
}
