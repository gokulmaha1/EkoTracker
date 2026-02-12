const db = require('../config/db');

// Haversine formula to calculate distance between two points
function calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Radius of the earth in km
    const dLat = deg2rad(lat2 - lat1);
    const dLon = deg2rad(lon2 - lon1);
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const d = R * c; // Distance in km
    return d;
}

function deg2rad(deg) {
    return deg * (Math.PI / 180);
}

exports.optimizeRoute = async (req, res) => {
    const { store_ids, start_lat, start_lng } = req.body;

    if (!store_ids || store_ids.length === 0) {
        return res.status(400).json({ message: 'No stores provided' });
    }

    try {
        // Fetch store details
        // Dynamically create placeholders based on array length
        const placeholders = store_ids.map(() => '?').join(',');
        const query = `SELECT * FROM stores WHERE id IN (${placeholders})`;
        const [stores] = await db.execute(query, store_ids);

        if (stores.length === 0) {
            return res.status(404).json({ message: 'Stores not found' });
        }

        // Nearest Neighbor Algorithm
        let currentLat = start_lat || stores[0].lat; // Default to first store if no start provided (not ideal but fallback)
        let currentLng = start_lng || stores[0].lng;

        let unvisited = [...stores];
        let route = [];

        while (unvisited.length > 0) {
            let nearestStore = null;
            let minDistance = Infinity;
            let nearestIndex = -1;

            for (let i = 0; i < unvisited.length; i++) {
                const store = unvisited[i];
                if (store.lat && store.lng) {
                    const dist = calculateDistance(currentLat, currentLng, store.lat, store.lng);
                    if (dist < minDistance) {
                        minDistance = dist;
                        nearestStore = store;
                        nearestIndex = i;
                    }
                }
            }

            if (nearestStore) {
                route.push(nearestStore);
                currentLat = nearestStore.lat;
                currentLng = nearestStore.lng;
                unvisited.splice(nearestIndex, 1);
            } else {
                // Should not happen unless stores have no lat/lng
                // Add remaining and break
                route.push(...unvisited);
                break;
            }
        }

        res.json(route);

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};
