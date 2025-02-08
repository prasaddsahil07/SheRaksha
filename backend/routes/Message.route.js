import express from "express";
import { sendMessage, getMessages } from "../controllers/Message.controller.js";
import upload from "../middleware/fileHandle.js";
import { isAuthenticated } from "../middleware/authMiddleware.js"; // Ensure authentication

const router = express.Router();

// Upload multiple file types
router.post(
  "/send/:id",
  isAuthenticated,
  upload.fields([{ name: "image" }, { name: "audio" }]),
  sendMessage
);
router.get("/get/:id", isAuthenticated, getMessages);


export default router;
