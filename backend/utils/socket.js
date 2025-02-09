import http from "http";
import express from "express";
import { Server } from "socket.io";

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
    cors: {
        origin: "*", // Adjust as needed
    },
});


io.on("connection", function (socket) {
    console.log(`Connection Established by ${socket.id}`);
    socket.on("send-location", function (data) {
        console.log(`Location updated by ${socket.id}`)
        console.log(data);
        io.emit("recieve-location", { id: socket.id, ...data }, );
    });

    socket.on("disconnect", function () {
        io.emit("user-disconnected", socket.id);
    });
});

export { app, server, io };