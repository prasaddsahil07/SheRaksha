import express from 'express';
import { sendLocation } from '../controllers/Location.controller.js';
import { isAuthenticated } from '../middleware/authMiddleware.js';

const router = express.Router();

// router.post('/update', isAuthenticated, updateLocation);
router.post('/:userId', isAuthenticated, sendLocation);

export default router;
