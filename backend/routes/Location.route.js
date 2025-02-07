import express from 'express';
import { updateLocation } from '../controllers/Location.controller.js';
import { isAuthenticated } from '../middleware/authMiddleware.js';

const router = express.Router();

router.post('/update', isAuthenticated, updateLocation);
// router.get('/:friendId', isAuthenticated, getFriendLocation);

export default router;
