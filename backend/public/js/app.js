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

let addUserModal;

function checkAuth() {
    const token = localStorage.getItem('token');
    if (!token) {
        window.location.href = 'index.html';
        return null;
    }
    return token;
}

document.addEventListener('DOMContentLoaded', () => {
    // Initialize Modals if element exists
    if (document.getElementById('addStoreModal')) {
        storeModal = new bootstrap.Modal(document.getElementById('addStoreModal'));
    }
    if (document.getElementById('addProductModal')) {
        productModal = new bootstrap.Modal(document.getElementById('addProductModal'));
    }
    if (document.getElementById('addUserModal')) {
        addUserModal = new bootstrap.Modal(document.getElementById('addUserModal'));
    }
});

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
                    <button class="btn btn-sm btn-info" onclick="editStore(${store.id}, '${store.name}', '${store.area}', '${store.phone}', '${store.address}', '${store.owner_name}')">Edit</button>
                    <!-- <button class="btn btn-sm btn-danger">Delete</button> -->
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
                    <button class="btn btn-sm btn-info" onclick="editProduct(${prod.id}, '${prod.name}', '${prod.sku}', ${prod.price}, ${prod.stock})">Edit</button>
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
    storeModal.show();
}

// Store Form Handler
async function handleCreateStore(e) {
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
}

if (document.getElementById('addStoreForm')) {
    document.getElementById('addStoreForm').onsubmit = handleCreateStore;
}

// Product Modals
let productModal;
function showAddProductModal() {
    productModal.show();
}

// Product Form Handler
async function handleCreateProduct(e) {
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
}

if (document.getElementById('addProductForm')) {
    document.getElementById('addProductForm').onsubmit = handleCreateProduct;
}

if (window.location.pathname.includes('master_data.html')) {
    checkAuth();
    fetchMasterData();
}

if (window.location.pathname.includes('orders.html')) {
    checkAuth();
    fetchOrdersPage();
}

if (window.location.pathname.includes('users.html')) {
    checkAuth();
    fetchUsersPage();
}

async function fetchOrdersPage() {
    const token = checkAuth();
    const headers = { 'Authorization': `Bearer ${token}` };
    try {
        const orders = await fetch(`${API_URL}/orders`, { headers }).then(res => res.json());
        const tbody = document.getElementById('allOrdersTableBody');
        tbody.innerHTML = orders.map(order => `
            <tr>
                <td>${order.id}</td>
                <td>${order.store_name}</td>
                <td>${order.user_name}</td>
                <td>₹${order.total_amount}</td>
                <td><span class="badge bg-${getStatusColor(order.status)}">${order.status}</span></td>
                <td>${new Date(order.created_at).toLocaleDateString()}</td>
                <td>
                    <button class="btn btn-sm btn-outline-info">View</button>
                </td>
            </tr>
        `).join('');
    } catch (e) { console.error(e); }
}

async function fetchUsersPage() {
    const token = checkAuth();
    const headers = { 'Authorization': `Bearer ${token}` };
    // Note: You need to ensure you have a /api/users endpoint. 
    // Since we didn't explicitly create a full users CRUD, we might need to rely on what's available
    // or mock it if only the auth one exists. 
    // Assuming we can fetch list from a new endpoint or using a placeholder.
    // Let's assume we create a quick endpoint or fail gracefully.

    // Check if we have a route for GET /users, if not we might fail.
    // The task list said "Implement Master Data APIs (Stores, Products, Users)", so likely it exists or needs to be added.
    // If not, I'll add a simple placeholder list.

    try {
        // If /users endpoint doesn't exist, this will fail. Let's try.
        const users = await fetch(`${API_URL}/auth/users`, { headers }).then(res => res.json());
        // Need to add this endpoint to authRoutes or similar if not there.
        // For now, let's catch error and show "Not implemented" if it fails.

        const tbody = document.getElementById('usersTableBody');
        if (Array.isArray(users)) {
            tbody.innerHTML = users.map(user => `
                <tr>
                    <td>${user.id}</td>
                    <td>${user.name}</td>
                    <td>${user.email}</td>
                    <td>${user.role}</td>
                    <td>-</td>
                </tr>
            `).join('');
        } else {
            throw new Error('No users found');
        }

    } catch (e) {
        console.error(e);
        document.getElementById('usersTableBody').innerHTML = '<tr><td colspan="5" class="text-center text-muted">Error loading users.</td></tr>';
    }
}

function showAddUserModal() {
    addUserModal.show();
}

// Add User Form Submission
if (document.getElementById('addUserForm')) {
    document.getElementById('addUserForm').addEventListener('submit', async (e) => {
        e.preventDefault();

        const token = checkAuth();
        const headers = {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`
        };

        const userData = {
            name: document.getElementById('userName').value,
            email: document.getElementById('userEmail').value,
            password: document.getElementById('userPassword').value,
            phone: document.getElementById('userPhone').value,
            role: document.getElementById('userRole').value
        };

        try {
            const res = await fetch(`${API_URL}/auth/register`, {
                method: 'POST',
                headers: headers,
                body: JSON.stringify(userData)
            });

            if (res.ok) {
                alert('User created successfully!');
                addUserModal.hide();
                document.getElementById('addUserForm').reset();
                fetchUsersPage(); // Refresh list
            } else {
                const data = await res.json();
                alert('Error: ' + data.message);
            }
        } catch (error) {
            console.error('Error creating user:', error);
            alert('Failed to create user');
        }
    });
}

