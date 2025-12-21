const UserRepository = require('../repositories/UserRepository');
const { hashPassword, comparePassword, validatePassword } = require('../utils/password.util');
const { generateToken } = require('../utils/jwt.util');

/**
 * Service layer for authentication business logic
 */
class AuthService {
  /**
   * Register a new user
   * @param {Object} userData - User registration data
   * @returns {Promise<Object>} User and token
   */
  async register({ fullName, email, password }) {
    // Validate input
    if (!fullName || !email || !password) {
      throw new Error('Full name, email, and password are required');
    }

    // Validate password strength
    const passwordValidation = validatePassword(password);
    if (!passwordValidation.isValid) {
      throw new Error(passwordValidation.errors.join(', '));
    }

    // Check if user already exists
    const existingUser = await UserRepository.findByEmail(email);
    if (existingUser) {
      throw new Error('User with this email already exists');
    }

    // Hash password
    const passwordHash = await hashPassword(password);

    // Create user
    const user = await UserRepository.create({
      fullName,
      email: email.toLowerCase(),
      passwordHash,
      preferences: {
        themeMode: 'system',
        language: 'en',
      },
    });

    // Generate JWT token
    const token = generateToken({
      userId: user._id.toString(),
      email: user.email,
    });

    // Return user without password hash
    return {
      user: user.toJSON(), // toJSON method removes passwordHash
      token,
    };
  }

  /**
   * Login user with email and password
   * @param {Object} credentials - Login credentials
   * @returns {Promise<Object>} User and token
   */
  async login({ email, password }) {
    // Validate input
    if (!email || !password) {
      throw new Error('Email and password are required');
    }

    // Find user by email
    const user = await UserRepository.findByEmail(email);
    if (!user) {
      throw new Error('Invalid email or password');
    }

    // Verify password
    const isPasswordValid = await comparePassword(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new Error('Invalid email or password');
    }

    // Generate JWT token
    const token = generateToken({
      userId: user._id.toString(),
      email: user.email,
    });

    // Return user without password hash
    return {
      user: user.toJSON(),
      token,
    };
  }

  /**
   * Get current user by ID
   * @param {string} userId - User ID
   * @returns {Promise<Object>} User data
   */
  async getCurrentUser(userId) {
    const user = await UserRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    return user.toJSON();
  }

  /**
   * Update user preferences
   * @param {string} userId - User ID
   * @param {Object} preferences - Preferences to update
   * @returns {Promise<Object>} Updated user
   */
  async updatePreferences(userId, preferences) {
    const user = await UserRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    // Merge with existing preferences
    const updatedPreferences = {
      ...user.preferences,
      ...preferences,
    };

    const updatedUser = await UserRepository.updatePreferences(userId, updatedPreferences);
    return updatedUser.toJSON();
  }

  /**
   * Change user password
   * @param {string} userId - User ID
   * @param {string} currentPassword - Current password
   * @param {string} newPassword - New password
   * @returns {Promise<Object>} Success message
   */
  async changePassword(userId, currentPassword, newPassword) {
    const user = await UserRepository.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    // Verify current password
    const isPasswordValid = await comparePassword(currentPassword, user.passwordHash);
    if (!isPasswordValid) {
      throw new Error('Current password is incorrect');
    }

    // Validate new password
    const passwordValidation = validatePassword(newPassword);
    if (!passwordValidation.isValid) {
      throw new Error(passwordValidation.errors.join(', '));
    }

    // Hash new password
    const newPasswordHash = await hashPassword(newPassword);

    // Update user
    await UserRepository.update(userId, { passwordHash: newPasswordHash });

    return { message: 'Password changed successfully' };
  }
}

module.exports = new AuthService(); // Export singleton instance
