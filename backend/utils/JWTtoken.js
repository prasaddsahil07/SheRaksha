export const sendToken = (user, statusCode, res, message) => {
    const token = user.getJWTToken();
    const cookieExpireInDays = parseInt(process.env.COOKIE_EXPIRE || '7', 10);
    const options = {
        expires: new Date(
            Date.now() + cookieExpireInDays * 24 * 60 * 60 * 1000
        ),
        httpOnly: true, // Set httpOnly to true
    };

    res.status(statusCode).cookie("token", token, options).json({
        success: true,
        user,
        message,
    });
};