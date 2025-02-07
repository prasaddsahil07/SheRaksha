import { Router } from "express";
import { addFriend, removeFriend, getFriends } from "../controllers/Friend.controller.js";
import { isAuthenticated } from "../middleware/authMiddleware.js";

const router = Router();

router.post("/add", isAuthenticated, addFriend);
router.post("/remove", isAuthenticated, removeFriend);
router.get("/list", isAuthenticated, getFriends);

export default router;