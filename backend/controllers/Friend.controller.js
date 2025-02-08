import { catchAsyncErrors } from "../middleware/catchAsyncError.js";
import ErrorHandler from "../middleware/error.js";
import User from "../models/User.model.js";

// ✅ Add a Friend (Max 10 Friends)
export const addFriend = catchAsyncErrors(async (req, res, next) => {
    const { friendEmail } = req.body;

    // ✅ Find logged-in user
    // console.log(req.cookies.token);
    const user = await User.findById(req.user._id);
    if (!user) return next(new ErrorHandler('User not found', 404));

    // ✅ Find friend by email
    const friend = await User.findOne({ email: friendEmail });
    if (!friend) return next(new ErrorHandler('Friend not found', 404));

    // ❌ Prevent self-addition
    if (user.email === friend.email) {
        return next(new ErrorHandler('You cannot add yourself as a friend', 400));
    }

    // ❌ Prevent duplicate friendships
    if (user.friends.includes(friend._id)) {
        return next(new ErrorHandler('Already friends', 400));
    }

    // ❌ Prevent more than 10 friends
    if (user.friends.length >= 10) {
        return next(new ErrorHandler('Max 10 friends allowed!', 400));
    }

    // ✅ Add friends to each other's lists
    user.friends.push(friend._id);
    friend.friends.push(user._id);

    await user.save();
    await friend.save();

    res.status(200).json({ success: true, message: 'Friend added', friend });
});

// ✅ Remove a Friend
export const removeFriend = catchAsyncErrors(async (req, res, next) => {
    const { friendId } = req.body;

    // ✅ Find logged-in user
    const user = await User.findById(req.user._id);
    if (!user) return next(new ErrorHandler('User not found', 404));

    // ✅ Find friend
    const friend = await User.findById(friendId);
    if (!friend) return next(new ErrorHandler('Friend not found', 404));

    // ✅ Remove friend from user's list
    user.friends = user.friends.filter(id => id.toString() !== friendId);
    await user.save();

    // ✅ Remove user from friend's list
    friend.friends = friend.friends.filter(id => id.toString() !== req.user._Id);
    await friend.save();

    res.status(200).json({ success: true, message: 'Friend removed' });
});

// ✅ Get All Friends
export const getFriends = catchAsyncErrors(async (req, res, next) => {
    const user = await User.findById(req.user._id).populate('friends', 'firstName email');
    res.status(200).json({ success: true, friends: user.friends });
});
