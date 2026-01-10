const User = require('../models/User');

/**
 * Repository for User data access
 * Implements Repository Pattern to abstract database operations
 */
class UserRepository {
  /**
   * Find user by email
   * @param {string} email - User email
   * @returns {Promise<User|null>} User document or null
   */
  async findByEmail(email) {
    return await User.findOne({ email: email.toLowerCase(), isActive: true });
  }

  /**
   * Find user by ID
   * @param {string} userId - User ID
   * @returns {Promise<User|null>} User document or null
   */
  async findById(userId) {
    return await User.findOne({ _id: userId, isActive: true });
  }

  /**
   * Create a new user
   * @param {Object} userData - User data
   * @returns {Promise<User>} Created user document
   */
  async create(userData) {
    const user = new User(userData);
    return await user.save();
  }

  /**
   * Update user by ID
   * @param {string} userId - User ID
   * @param {Object} updateData - Data to update
   * @returns {Promise<User|null>} Updated user or null
   */
  async update(userId, updateData) {
    return await User.findByIdAndUpdate(
      userId,
      { ...updateData, updatedAt: new Date() },
      { new: true, runValidators: true }
    );
  }

  /**
   * Update user preferences
   * @param {string} userId - User ID
   * @param {Object} preferences - Preferences to update
   * @returns {Promise<User|null>} Updated user or null
   */
  async updatePreferences(userId, preferences) {
    return await User.findByIdAndUpdate(
      userId,
      { 
        preferences: preferences,
        updatedAt: new Date() 
      },
      { new: true, runValidators: true }
    );
  }

  /**
   * Update last sync time
   * @param {string} userId - User ID
   * @returns {Promise<User|null>} Updated user or null
   */
  async updateLastSync(userId) {
    return await User.findByIdAndUpdate(
      userId,
      { lastSyncAt: new Date() },
      { new: true }
    );
  }

  /**
   * Soft delete a user
   * @param {string} userId - User ID
   * @returns {Promise<User|null>} Deleted user or null
   */
  async softDelete(userId) {
    return await User.findByIdAndUpdate(
      userId,
      { 
        isActive: false, 
        deletedAt: new Date() 
      },
      { new: true }
    );
  }

  /**
   * Check if email exists
   * @param {string} email - Email to check
   * @returns {Promise<boolean>} True if email exists
   */
  async emailExists(email) {
    const user = await User.findOne({ email: email.toLowerCase() });
    return !!user;
  }

  /**
   * Get user count (for admin/analytics)
   * @returns {Promise<number>} Total active users
   */
  async count() {
    return await User.countDocuments({ isActive: true });
  }
}

module.exports = new UserRepository(); // Export singleton instance
