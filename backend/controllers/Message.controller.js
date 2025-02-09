import Message from "../models/Message.model.js";
import User from "../models/User.model.js";
import { io } from "../utils/socket.js"; // Import Socket.io instance
import cloudinary from "../utils/cloudinary.js"; // Assuming Cloudinary is used

export const getMessages = async (req, res) => {
  try {
    const { id: friendId } = req.params; // ID of the friend
    const userId = req.user._id; // ID of the logged-in user

    // Ensure the friend exists in the user's friends list
    const user = await User.findById(userId).populate("friends");
    const isFriend = user.friends.some((friend) => friend._id.toString() === friendId);
    
    if (!isFriend) {
      return res.status(403).json({ error: "You can only view messages from your friends." });
    }

    // Retrieve messages exchanged between the user and the friend, sorted by timestamp
    const messages = await Message.find({
      $or: [
        { senderId: userId, receiverId: friendId },
        { senderId: friendId, receiverId: userId },
      ],
    }).sort({ createdAt: 1 }); // Sort by time (oldest to newest)

    res.status(200).json(messages);
  } catch (error) {
    console.error("Error in getMessages controller:", error.message);
    res.status(500).json({ error: "Internal server error" });
  }
};


export const sendMessage = async (req, res) => {
  try {
    const { text } = req.body;
    console.log(req.body);
    
    const senderId = req.user._id;

    let imageUrl = null, audioUrl = null;

    // Check if files exist in request
    if (req.files) {
      if (req.files["image"] && req.files["image"].length > 0) {
        const uploadedImage = await cloudinary.uploader.upload(req.files["image"][0].path);
        imageUrl = uploadedImage.secure_url;
      }
      if (req.files["audio"] && req.files["audio"].length > 0) {
        const uploadedAudio = await cloudinary.uploader.upload(req.files["audio"][0].path, {
          resource_type: "video",
        });
        audioUrl = uploadedAudio.secure_url;
      }
    }

    // Create new message object
    const message = new Message({
      senderId,
      text: text || "", // Ensure text field is always present
      image: imageUrl,
      audio: audioUrl,
    });

    // Save message to database
    const newMessage = await message.save();

    // Fetch the sender's friends
    // const sender = await User.findById(senderId).populate("friends");

    io.emit("newMessage", newMessage, senderId);
      

    // Send response back to sender
    res.status(201).json(newMessage);
  } catch (error) {
    console.error("Error in sendMessage controller:", error.message);
    res.status(500).json({ error: "Internal server error" });
  }
};
