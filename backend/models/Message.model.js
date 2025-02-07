import mongoose from "mongoose";

const messageSchema = new mongoose.Schema(
    {
        senderId:{
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true
        },
        receiverId:{
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true
        },
        text:{type: String},
        image:{type: String},
        audio:{type: String},
        video:{type:String}
    },
    {timestamps: true}
);

export default mongoose.model("Message", messageSchema);