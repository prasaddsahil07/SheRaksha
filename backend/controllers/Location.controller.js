import Location from '../models/Location.model.js';
// import { io } from '../services/socketService.js';

// Haversine formula to calculate distance between two coordinates (in meters)
const getDistance = (lat1, lon1, lat2, lon2) => {
    const R = 6371000; // Earth's radius in meters
    const toRad = (deg) => (deg * Math.PI) / 180;
    const dLat = toRad(lat2 - lat1);
    const dLon = toRad(lon2 - lon1);
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
};

// Update location only if moved more than 50 meters or after 60 seconds
export const updateLocation = async (req, res) => {
    try {
        const { latitude, longitude } = req.body;
        const userId = req.userId;

        let location = await Location.findOne({ userId });

        if (location) {
            const distance = getDistance(location.latitude, location.longitude, latitude, longitude);
            const timeDiff = (new Date() - location.timestamp) / 1000; // Time in seconds

            if (distance < 50 && timeDiff < 60) {
                return res.status(200).json({ message: 'Location update skipped (no significant movement)' });
            }
        }

        location = await Location.findOneAndUpdate(
            { userId },
            { latitude, longitude, timestamp: new Date() },
            { upsert: true, new: true }
        );

        // Send real-time update via Socket.io (no DB write)
        io.emit(`locationUpdate:${userId}`, location);

        res.status(200).json({ message: 'Location updated', location });
    } catch (error) {
        res.status(500).json({ message: 'Server error' });
    }
};
