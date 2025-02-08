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
    console.log("Connection Established");
    socket.on("send-location", function (data) {
        console.log("Location updated...")
        // console.log(socket.id, data);
        io.emit("recieve-location", { id: socket.id, ...data }, );
    });

    socket.on("disconnect", function () {
        io.emit("user-disconnected", socket.id);
    });
});

export { app, server, io };