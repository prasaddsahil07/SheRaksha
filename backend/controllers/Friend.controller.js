import { catchAsyncErrors } from "../middleware/catchAsyncError.js";
import ErrorHandler from "../middleware/error.js";
import User from "../models/User.model.js";

// Add a friend (max 10 friends)
export const addFriend = catchAsyncErrors(async (req, res, next) => {
    const { friendEmail } = req.body;
    const user = await User.findOne(req.email);
    const friend = await User.findOne({ email: friendEmail });

    if (!friend) {
        return next(new ErrorHandler('User not found', 404));
    }

    if (user.friends.includes(friend._id)) {
        return next(new ErrorHandler('Already friends', 400));
    }

    if (user.friends.length >= 10) {
        return next(new ErrorHandler('Max 10 friends allowed!', 400));
    }

    user.friends.push(friend._id);
    friend.friends.push(user._id);

    await user.save();
    await friend.save();

    res.status(200).json({ success: true, message: 'Friend added', friend });
});

// Remove a friend
export const removeFriend = catchAsyncErrors(async (req, res, next) => {
    const { friendId } = req.body;
    const user = await User.findOne(req.email);
    const friend = await User.findById(friendId);

    if (!friend) {
        return next(new ErrorHandler('Friend not found', 404));
    }

    // Remove friend from user's friend list
    user.friends = user.friends.filter(id => id.toString() !== friendId);
    await user.save();

    // Remove user from friend's friend list
    friend.friends = friend.friends.filter(id => id.toString() !== req.userId);
    await friend.save();

    res.status(200).json({ success: true, message: 'Friend removed' });
});

// Get all friends
export const getFriends = catchAsyncErrors(async (req, res, next) => {
    const user = await User.findById(req.userId).populate('friends', 'name email');
    res.status(200).json({ success: true, friends: user.friends });
});