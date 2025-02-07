import { catchAsyncErrors } from "../middleware/catchAsyncError.js";
import User from "../models/User.model.js";
import ErrorHandler from "../middleware/error.js";
import { sendToken } from "../utils/JWTtoken.js"

export const register = catchAsyncErrors(async (req, res, next) => {
    const { firstName, lastName, email, phone, password, gender, address } = req.body;
    if (!firstName || !lastName || !email || !phone || !password || !gender || !address) {
        return next(new ErrorHandler("Please fill The entire form!"));
    }
    const isEmail = await User.findOne({ email });
    if (isEmail) {
        return next(new ErrorHandler("Email already registered!"));
    }
    const user = await User.create({
        firstName,
        lastName,
        email,
        phone,
        password,
        gender,
        address,
        phone,
        friends: [],
    });
    sendToken(user, 200, res, "User Registered!");
});

export const login = catchAsyncErrors(async (req, res, next) => {
    const { email, password, gender } = req.body;
    if (!email || !password || !gender) {
        return next(new ErrorHandler("Please provide email ,password and role."));
    }
    const user = await User.findOne({ email });
    if (!user) {
        return next(new ErrorHandler("Invalid Email Or Password.", 400));
    }
    const isPasswordMatched = await user.comparePassword(password);
    if (!isPasswordMatched) {
        return next(new ErrorHandler("Invalid Email Or Password.", 400));
    }
    if (user.gender !== gender) {
        return next(new ErrorHandler(`User with provided email and ${gender} not found!`, 404));
    }
    sendToken(user, 201, res, "User Logged In!");
});

export const logout = catchAsyncErrors(async (req, res, next) => {
    res
        .status(200)
        .cookie("token", "", {
            httpOnly: true,
            expires: new Date(Date.now()),
        })
        .json({
            success: true,
            message: "Logged Out Successfully.",
        });
});


export const getUser = catchAsyncErrors(async (req, res, next) => {
    const user = await User.findById(req.params.id);
    if (!user) {
        return res.status(404).json({
            success: false,
            message: "User not found",
        });
    }

    res.status(200).json({
        success: true,
        user,
    });
});
