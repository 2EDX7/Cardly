const User = require('../models/User');

/**
 * Register FCM token for user
 * POST /api/notifications/register-token
 */
exports.registerToken = async (req, res) => {
  try {
    const { token } = req.body;
    const userId = req.user.userId; // From auth middleware

    if (!token) {
      return res.status(400).json({
        success: false,
        message: 'Token is required'
      });
    }

    // Add token to user's fcmTokens array (prevents duplicates with $addToSet)
    await User.findByIdAndUpdate(
      userId,
      { $addToSet: { fcmTokens: token } },
      { new: true }
    );

    console.log(`✅ FCM token registered for user ${userId}`);

    res.status(200).json({
      success: true,
      message: 'Token registered successfully'
    });
  } catch (error) {
    console.error('Register token error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to register token'
    });
  }
};

/**
 * Remove FCM token (on logout)
 * POST /api/notifications/remove-token
 */
exports.removeToken = async (req, res) => {
  try {
    const { token } = req.body;
    const userId = req.user.userId;

    if (!token) {
      return res.status(400).json({
        success: false,
        message: 'Token is required'
      });
    }

    // Remove token from user's fcmTokens array
    await User.findByIdAndUpdate(
      userId,
      { $pull: { fcmTokens: token } }
    );

    console.log(`✅ FCM token removed for user ${userId}`);

    res.status(200).json({
      success: true,
      message: 'Token removed successfully'
    });
  } catch (error) {
    console.error('Remove token error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to remove token'
    });
  }
};
