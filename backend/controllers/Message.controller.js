import Message from "../models/Message.model.js";
import cloudinary from "../utils/cloudinary.js";
import { getReceiverSocketId, io } from "../utils/socket.js";

export const getMessages = async (req, res) => {
  try {
    const { id: userToChatId } = req.params;
    const myId = req.user._id;

    const messages = await Message.find({
      $or: [
        { senderId: myId, receiverId: userToChatId },
        { senderId: userToChatId, receiverId: myId },
      ],
    });

    res.status(200).json(messages);
  } catch (error) {
    console.log("Error in getMessages controller: ", error.message);
    res.status(500).json({ error: "Internal server error" });
  }
};

export const sendMessage = async (req, res) => {
  try {
    const { text, image, audio, video } = req.body;
    const { id: receiverId } = req.params;
    const senderId = req.user._id;

    let imageUrl, audioUrl, videoUrl;
    if (image) {
      const uploadResponse = await cloudinary.uploader.upload(image);
      imageUrl = uploadResponse.secure_url;
    }

    if (audio) {
        const uploadResponse = await cloudinary.uploader.upload(audio, {
            resource_type: "video",
        });
        audioUrl = uploadResponse.secure_url;
    }
      
    if (video) {
        const uploadResponse = await cloudinary.uploader.upload(video, {
            resource_type: "video",
        });
        videoUrl = uploadResponse.secure_url;
    }
      

    const newMessage = new Message({
      senderId,
      receiverId,
      text,
      image: imageUrl,
    });

    await newMessage.save();

    const sender = await User.findById(senderId).populate("friends");
    sender.friends.forEach((friend) => {
        const friendSocketId = userSockets.get(friend._id.toString());
        if (friendSocketId) {
            io.to(friendSocketId).emit("newMessage", newMessage);
        }
    });
    res.status(201).json(newMessage);
  } catch (error) {
    console.log("Error in sendMessage controller: ", error.message);
    res.status(500).json({ error: "Internal server error" });
  }
};