import express from "express";
import http from "http";
import dotenv from "dotenv";
import cors from "cors";
import cookieParser from "cookie-parser";
import { connectDB } from "./db/connectDB.js";
import { errorMiddleware } from "./middleware/error.js";
import userRouter from "./routes/User.route.js";
import friendRouter from "./routes/Friend.route.js";
import locationRouter from "./routes/Location.route.js";
import { Server } from "socket.io";
import User from "./models/User.model.js";

dotenv.config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.FRONTEND_URL,
    methods: ["GET", "POST", "DELETE", "PUT"],
    credentials: true,
  },
});

await connectDB();

const userSockets = new Map(); // Stores userId -> socketId mapping

io.on("connection", async (socket) => {
  console.log("User connected:", socket.id);

  socket.on("join-room", (userId) => {
    userSockets.set(userId, socket.id); // Store the user's socket ID
    console.log(`User ${userId} joined with socket ${socket.id}`);
  });

  socket.on("send-location", async ({ userId, lat, lon }) => {
    try {
      // Fetch user's friends from DB
      const user = await User.findById(userId).populate("friends");

      if (!user) return;

      // Send location only to the user's friends
      user.friends.forEach((friend) => {
        const friendSocketId = userSockets.get(friend._id.toString());
        if (friendSocketId) {
          io.to(friendSocketId).emit("receive-location", { userId, lat, lon });
        }
      });
    } catch (error) {
      console.error("Error broadcasting location:", error);
    }
  });

  socket.on("send-emergency", async ({ userId, lat, lon, image, audio }) => {
    try {
      // Fetch user's friends from DB
      const user = await User.findById(userId).populate("friends");

      if (!user) return;

      // Send emergency alert to all friends
      user.friends.forEach((friend) => {
        const friendSocketId = userSockets.get(friend._id.toString());
        if (friendSocketId) {
          io.to(friendSocketId).emit("receive-emergency", { userId, lat, lon, image, audio });
        }
      });
    } catch (error) {
      console.error("Error broadcasting emergency alert:", error);
    }
  });

  socket.on("disconnect", () => {
    console.log("User disconnected:", socket.id);
    userSockets.forEach((value, key) => {
      if (value === socket.id) {
        userSockets.delete(key);
      }
    });
  });
});

// Express Middleware
app.use(cors({ origin: process.env.FRONTEND_URL, methods: ["GET", "POST", "DELETE", "PUT"], credentials: true }));
app.use(cookieParser());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use("/api/v1/user", userRouter);
app.use("/api/v1/friend", friendRouter);
app.use("/api/v1/location", locationRouter);
app.use(errorMiddleware);

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}...`));

export default app;
