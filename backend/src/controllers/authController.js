const AuthService = require('../services/AuthService');

/**
 * Controller for authentication endpoints
 * Handles HTTP requests and responses
 */

/**
 * Register a new user
 * POST /api/auth/register
 */
async function register(req, res) {
  try {
    const { fullName, email, password } = req.body;

    const result = await AuthService.register({ fullName, email, password });

    res.status(201).json({
      success: true,
      data: result,
    });
  } catch (error) {
    console.error('Registration error:', error.message);
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
}

/**
 * Login user
 * POST /api/auth/login
 */
async function login(req, res) {
  try {
    const { email, password } = req.body;

    const result = await AuthService.login({ email, password });

    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    console.error('Login error:', error.message);
    res.status(401).json({
      success: false,
      message: error.message,
    });
  }
}

/**
 * Get current authenticated user
 * GET /api/auth/me
 */
async function getCurrentUser(req, res) {
  try {
    // req.user is set by auth middleware
    const userId = req.user.userId;

    const user = await AuthService.getCurrentUser(userId);

    res.status(200).json({
      success: true,
      data: { user },
    });
  } catch (error) {
    console.error('Get current user error:', error.message);
    res.status(404).json({
      success: false,
      message: error.message,
    });
  }
}

/**
 * Update user preferences
 * PATCH /api/users/preferences
 */
async function updatePreferences(req, res) {
  try {
    const userId = req.user.userId;
    const { themeMode, language, receiveNotifications } = req.body;

    const preferences = {};
    if (themeMode) preferences.themeMode = themeMode;
    if (language) preferences.language = language;
    if (receiveNotifications !== undefined) preferences.receiveNotifications = receiveNotifications;

    const user = await AuthService.updatePreferences(userId, preferences);

    res.status(200).json({
      success: true,
      data: { user },
    });
  } catch (error) {
    console.error('Update preferences error:', error.message);
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
}

/**
 * Change password
 * POST /api/auth/change-password
 */
async function changePassword(req, res) {
  try {
    const userId = req.user.userId;
    const { currentPassword, newPassword } = req.body;

    const result = await AuthService.changePassword(userId, currentPassword, newPassword);

    res.status(200).json({
      success: true,
      message: result.message,
    });
  } catch (error) {
    console.error('Change password error:', error.message);
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
}

module.exports = {
  register,
  login,
  getCurrentUser,
  updatePreferences,
  changePassword,
};
