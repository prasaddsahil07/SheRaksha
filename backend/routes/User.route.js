import { Router } from "express";
import { login, register, logout, getUser } from "../controllers/User.controller.js";
import { isAuthenticated } from "../middleware/authMiddleware.js";

const router = Router();

router.post("/register", register);
router.post("/login", login);
router.post("/logout", isAuthenticated, logout);
router.get("/getuser/:id", isAuthenticated, getUser);

export default router;