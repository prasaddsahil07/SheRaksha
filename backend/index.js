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
// import { initSocket } from './services/socketService.js';

// import authMiddlewareSocket from "./middleware/authMiddlewareSocket.js"; // For socket authentication

dotenv.config();

const app = express();
// const server = http.createServer(app); // Create HTTP server for Express
// initSocket(server);

app.use(
    cors({
        origin: [process.env.FRONTEND_URL],
        method: ["GET", "POST", "DELETE", "PUT"],
        credentials: true,
    })
);
  
app.use(cookieParser());      // for authorization, cookie parser is mandatory
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

await connectDB();

// Listen for WebSocket connections
// io.on("connection", async (socket) => {
//   console.log("User connected:", socket.id);

//   // Authenticate socket connection
//   authMiddlewareSocket(socket, async (err, userId) => {
//     if (err) {
//       console.error("Authentication failed:", err);
//       return socket.disconnect();
//     }

//     console.log("Authenticated user:", userId);

//     // Listen for "updateLocation" event
//     socket.on("updateLocation", async ({ lat, lon }) => {
//       try {
//         // Update user location in DB
//         await User.findByIdAndUpdate(userId, { location: { lat, lon } });
//         console.log(`Updated location for user ${userId}: (${lat}, ${lon})`);
//       } catch (error) {
//         console.error("Error updating location:", error);
//       }
//     });

//     socket.on("disconnect", () => {
//       console.log("User disconnected:", userId);
//     });
//   });
// });

app.use("/api/v1/user", userRouter);
app.use("/api/v1/friend", friendRouter);
app.use("/api/v1/location", locationRouter);


app.use(errorMiddleware);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}...`));


export default app;