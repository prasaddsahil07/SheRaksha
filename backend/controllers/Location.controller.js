// // Haversine formula to calculate distance between two coordinates (in meters)
// const getDistance = (lat1, lon1, lat2, lon2) => {
//     const R = 6371000; // Earth's radius in meters
//     const toRad = (deg) => (deg * Math.PI) / 180;
//     const dLat = toRad(lat2 - lat1);
//     const dLon = toRad(lon2 - lon1);
//     const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
//         Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
//         Math.sin(dLon / 2) * Math.sin(dLon / 2);
//     const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
//     return R * c;
// };

import User from "../models/User.model.js";
import { io } from "../utils/socket.js";

export const sendLocation = async (req, res) => {
    try {
        const { userId } = req.params;  // User who is sending the location
        const { latitude, longitude } = req.body;

        if (!latitude || !longitude) {
            return res.status(400).json({ success: false, message: "Latitude and longitude are required" });
        }

        // Fetch the user's friends from the database
        const user = await User.findById(userId).populate("friends");

        if (!user) {
            return res.status(404).json({ success: false, message: "User not found" });
        }

        // Broadcast the location to each friend
        user.friends.forEach(friend => {
            io.emit(`location-update-${friend._id}`, { userId, latitude, longitude, timestamp: Date.now() });
        });

        return res.status(200).json({
            success: true,
            message: "Location sent and broadcasted successfully",
        });

    } catch (error) {
        console.error("Error broadcasting location:", error);
        return res.status(500).json({ success: false, message: "Internal Server Error" });
    }
};
