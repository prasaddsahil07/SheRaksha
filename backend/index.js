import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import cookieParser from "cookie-parser";
import { connectDB } from "./db/connectDB.js";
import { errorMiddleware } from "./middleware/error.js";
import userRouter from "./routes/User.route.js";
import friendRouter from "./routes/Friend.route.js";
import locationRouter from "./routes/Location.route.js";
import messageRouter from "./routes/Message.route.js";
import { app, server } from "./utils/socket.js";


dotenv.config();

await connectDB();


// Express Middleware
app.use(cors({ origin: process.env.FRONTEND_URL, methods: ["GET", "POST", "DELETE", "PUT"], credentials: true }));
app.use(cookieParser());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use("/api/v1/user", userRouter);
app.use("/api/v1/friend", friendRouter);
app.use("/api/v1/location", locationRouter);
app.use("/api/v1/message", messageRouter);
app.use(errorMiddleware);

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}...`));