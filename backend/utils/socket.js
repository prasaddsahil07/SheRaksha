import { Server } from "socket.io";
import http from "http";
import express from "express";
import User from "../models/User.model.js";

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
    cors: {
        origin: process.env.FRONTEND_URL,
        methods: ["GET", "POST", "DELETE", "PUT"],
        credentials: true,
    },
});

export function getReceiverSocketId(userId) {
    return userSockets[userId];
}

const userSockets = new Map(); // Stores userId -> socketId mapping

io.on("connection", (socket) => {
    const userId = socket.handshake.query.userId;
    userSockets.set(userId, socket.id);
    console.log(`User ${userId} connected with socket ID ${socket.id}`);


    socket.on("sendMessage", async ({ senderId, content }) => {
        try {
            const user = await User.findById(senderId).populate("friends");
            if (!user) return;

            const newMessage = new Message({
                senderId,
                ...content, // content can include text, image URL, audio URL, video URL
            });

            await newMessage.save();

            user.friends.forEach((friend) => {
                const friendSocketId = userSockets.get(friend._id.toString());
                if (friendSocketId) {
                    io.to(friendSocketId).emit("newMessage", newMessage);
                }
            });
        } catch (error) {
            console.error("Error sending message:", error);
        }
    });

    socket.on("startLocationSharing", async ({ userId }) => {
        try {
            const user = await User.findById(userId).populate("friends");
            if (!user) return;

            user.friends.forEach((friend) => {
                const friendSocketId = userSockets.get(friend._id.toString());
                if (friendSocketId) {
                    io.to(friendSocketId).emit("friendStartedSharingLocation", { userId });
                }
            });
        } catch (error) {
            console.error("Error starting location sharing:", error);
        }
    });

    socket.on("updateLocation", async ({ userId, lat, lon }) => {
        const user = await User.findById(userId).populate("friends");
        if (!user) return;

        user.friends.forEach((friend) => {
            const friendSocketId = userSockets.get(friend._id.toString());
            if (friendSocketId) {
                io.to(friendSocketId).emit("friendLocationUpdate", { userId, lat, lon });
            }
        });
    });

    socket.on("stopLocationSharing", async ({ userId }) => {
        const user = await User.findById(userId).populate("friends");
        if (!user) return;

        user.friends.forEach((friend) => {
            const friendSocketId = userSockets.get(friend._id.toString());
            if (friendSocketId) {
                io.to(friendSocketId).emit("friendStoppedSharingLocation", { userId });
            }
        });
    });


    socket.on("sendEmergency", async ({ userId, lat, lon, image, audio }) => {
        try {
            const user = await User.findById(userId).populate("friends");
            if (!user) return;

            user.friends.forEach((friend) => {
                const friendSocketId = userSockets.get(friend._id.toString());
                if (friendSocketId) {
                    io.to(friendSocketId).emit("receiveEmergency", {
                        userId,
                        lat,
                        lon,
                        image,
                        audio,
                    });
                }
            });
        } catch (error) {
            console.error("Error sending emergency alert:", error);
        }
    });

    // Handle disconnection
    socket.on("disconnect", () => {
        userSockets.delete(userId);
        console.log(`User ${userId} disconnected`);
    });
});


export { io, app, server };