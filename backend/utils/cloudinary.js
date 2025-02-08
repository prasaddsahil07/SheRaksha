import { v2 as cloudinary } from "cloudinary";
import dotenv from "dotenv";

dotenv.config(); // Load environment variables

// Ensure the credentials are loaded properly
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME || "djarcit8v",
  api_key: process.env.CLOUDINARY_API_KEY || "662974288728786",
  api_secret: process.env.CLOUDINARY_API_SECRET || "IbdgNFqeWO0j1wCOEAnXWmyYoqA",
});

export default cloudinary;
