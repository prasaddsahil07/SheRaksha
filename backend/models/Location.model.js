import mongoose from 'mongoose';

const locationSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true },
    timestamp: { type: Date, default: Date.now },
    severity: { type:String, enum:["RED", "YELLOW", "GREEN"], required: true}
});

export default mongoose.model('Location', locationSchema);
