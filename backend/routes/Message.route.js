import express from "express";
import { isAuthenticated } from "../middleware/authMiddleware.js";
import { getMessages, sendMessage } from "../controllers/Message.controller.js";

const router = express.Router();

router.get("/:id", isAuthenticated, getMessages);
router.post("/send/:id", isAuthenticated, sendMessage);

export default router;