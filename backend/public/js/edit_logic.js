// Edit Store
function editStore(id, name, area, phone, address, owner_name) {
    document.getElementById('storeName').value = name;
    document.getElementById('storeArea').value = area !== 'null' ? area : '';
    document.getElementById('storePhone').value = phone !== 'null' ? phone : '';
    document.getElementById('storeAddress').value = address !== 'null' ? address : '';
    document.getElementById('storeOwner').value = owner_name !== 'null' && owner_name !== undefined ? owner_name : '';

    // Change form to update mode
    const form = document.getElementById('addStoreForm');
    form.onsubmit = async (e) => {
        e.preventDefault();
        await updateStore(id);
    };

    // Update modal title and button
    document.querySelector('#addStoreModal .modal-title').textContent = 'Edit Store';
    document.querySelector('#addStoreModal button[type="submit"]').textContent = 'Update Store';

    showAddStoreModal();
}

async function updateStore(id) {
    const token = checkAuth();
    const storeData = {
        name: document.getElementById('storeName').value,
        owner_name: document.getElementById('storeOwner').value,
        phone: document.getElementById('storePhone').value,
        area: document.getElementById('storeArea').value,
        address: document.getElementById('storeAddress').value,
        lat: 0,
        lng: 0,
        status: 'active'
    };

    try {
        const res = await fetch(`${API_URL}/stores/${id}`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(storeData)
        });
        if (!res.ok) throw new Error('Failed to update store');
        storeModal.hide();
        fetchMasterData();
        resetStoreForm();
    } catch (error) {
        alert(error.message);
    }
}

function resetStoreForm() {
    const form = document.getElementById('addStoreForm');
    form.reset();

    // Restore original create handler
    // We assume handleCreateStore is available globally or we reload
    // Reloading is safest to clear any state
    window.location.reload();
}


// Edit Product
function editProduct(id, name, sku, price, stock) {
    document.getElementById('prodName').value = name;
    document.getElementById('prodSku').value = sku !== 'null' ? sku : '';
    document.getElementById('prodPrice').value = price;
    document.getElementById('prodStock').value = stock;

    const form = document.getElementById('addProductForm');
    form.onsubmit = async (e) => {
        e.preventDefault();
        await updateProduct(id);
    };

    document.querySelector('#addProductModal .modal-title').textContent = 'Edit Product';
    document.querySelector('#addProductModal button[type="submit"]').textContent = 'Update Product';

    showAddProductModal();
}

async function updateProduct(id) {
    const token = checkAuth();
    const prodData = {
        name: document.getElementById('prodName').value,
        sku: document.getElementById('prodSku').value,
        price: document.getElementById('prodPrice').value,
        stock: document.getElementById('prodStock').value
    };

    try {
        const res = await fetch(`${API_URL}/products/${id}`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(prodData)
        });
        if (!res.ok) throw new Error('Failed to update product');
        productModal.hide();
        fetchMasterData();
        window.location.reload();
    } catch (error) {
        alert(error.message);
    }
}
