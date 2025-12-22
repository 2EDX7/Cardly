const Card = require('../models/Card');

/**
 * Repository for Card data access
 * Handles both profile cards and collected cards
 */
class CardRepository {
  // ==================== PROFILE CARD METHODS ====================
  
  /**
   * Find user's profile card
   * @param {string} userId - User ID (ownerId)
   * @returns {Promise<Card|null>} Profile card or null
   */
  async findProfileCard(userId) {
    return await Card.findOne({
      ownerId: userId,
      isProfileCard: true,
      isActive: true,
    });
  }

  /**
   * Create user's profile card
   * IMPORTANT: Each user can have ONLY ONE profile card
   * @param {string} userId - User ID
   * @param {Object} cardData - Card data
   * @returns {Promise<Card>} Created profile card
   */
  async createProfileCard(userId, cardData) {
    const card = new Card({
      ...cardData,
      ownerId: userId,
      isProfileCard: true,
      collectedAt: null, // Profile cards are never "collected"
    });
    
    return await card.save();
  }

  /**
   * Update user's profile card
   * @param {string} userId - User ID
   * @param {Object} updateData - Data to update
   * @returns {Promise<Card|null>} Updated profile card
   */
  async updateProfileCard(userId, updateData) {
    // IMPORTANT: Never update ownerId, isProfileCard, or shareableId
    const safeUpdate = { ...updateData };
    delete safeUpdate.ownerId;
    delete safeUpdate.isProfileCard;
    delete safeUpdate.shareableId; // Shareable ID is IMMUTABLE
    
    return await Card.findOneAndUpdate(
      { ownerId: userId, isProfileCard: true },
      { ...safeUpdate, updatedAt: new Date() },
      { new: true, runValidators: true }
    );
  }

  /**
   * Find profile card by shareable ID (for QR code scanning)
   * @param {string} shareableId - Shareable ID
   * @returns {Promise<Card|null>} Profile card or null
   */
  async findByShareableId(shareableId) {
    return await Card.findOne({
      shareableId: shareableId.toUpperCase(),
      isProfileCard: true,
      isPublic: true, // Only return if public
      isActive: true,
    });
  }

  /**
   * Check if shareable ID exists
   * @param {string} shareableId - Shareable ID to check
   * @returns {Promise<boolean>} True if exists
   */
  async shareableIdExists(shareableId) {
    const count = await Card.countDocuments({
      shareableId: shareableId.toUpperCase(),
    });
    return count > 0;
  }

  // ==================== COLLECTED CARD METHODS ====================
  
  /**
   * Find user's collected cards
   * @param {string} userId - User ID
   * @param {Object} filters - Optional filters (category, search, etc.)
   * @returns {Promise<Card[]>} Array of collected cards
   */
  async findCollectedCards(userId, filters = {}) {
    const query = {
      ownerId: userId,
      isProfileCard: false,
      isActive: true,
    };

    // Apply filters
    if (filters.category && filters.category !== 'all') {
      query.customCategory = filters.category;
    }

    if (filters.search) {
      query.$or = [
        { name: { $regex: filters.search, $options: 'i' } },
        { organization: { $regex: filters.search, $options: 'i' } },
        { jobTitle: { $regex: filters.search, $options: 'i' } },
      ];
    }

    const limit = filters.limit || 50;
    const offset = filters.offset || 0;

    const cards = await Card.find(query)
      .sort({ collectedAt: -1, createdAt: -1 })
      .skip(offset)
      .limit(limit)
      .populate('sourceCardId', 'shareableId'); // Populate shareableId from source card

    return cards;
  }

  /**
   * Count user's collected cards
   * @param {string} userId - User ID
   * @param {Object} filters - Optional filters
   * @returns {Promise<number>} Count of cards
   */
  async countCollectedCards(userId, filters = {}) {
    const query = {
      ownerId: userId,
      isProfileCard: false,
      isActive: true,
    };

    if (filters.category && filters.category !== 'all') {
      query.customCategory = filters.category;
    }

    if (filters.search) {
      query.$or = [
        { name: { $regex: filters.search, $options: 'i' } },
        { organization: { $regex: filters.search, $options: 'i' } },
        { jobTitle: { $regex: filters.search, $options: 'i' } },
      ];
    }

    return await Card.countDocuments(query);
  }

  /**
   * Add a collected card
   * This creates a NEW card (copy) in the user's collection
   * @param {string} userId - User ID
   * @param {Object} cardData - Card data
   * @returns {Promise<Card>} Created collected card
   */
  async addCollectedCard(userId, cardData) {
    const card = new Card({
      ...cardData,
      ownerId: userId,
      isProfileCard: false,
      collectedAt: new Date(),
      // Remove shareable ID - collected cards don't have one
      shareableId: undefined,
      isPublic: undefined,
    });

    return await card.save();
  }

  /**
   * Find a specific collected card by ID
   * @param {string} cardId - Card ID
   * @param {string} userId - User ID (for ownership check)
   * @returns {Promise<Card|null>} Card or null
   */
  async findCollectedCardById(cardId, userId) {
    return await Card.findOne({
      _id: cardId,
      ownerId: userId,
      isProfileCard: false,
      isActive: true,
    }).populate('sourceCardId', 'shareableId');
  }

  /**
   * Update a collected card
   * @param {string} cardId - Card ID
   * @param {string} userId - User ID (for ownership check)
   * @param {Object} updateData - Data to update
   * @returns {Promise<Card|null>} Updated card
   */
  async updateCollectedCard(cardId, userId, updateData) {
    // User can only update certain fields of collected cards
    const allowedUpdates = {
      customCategory: updateData.customCategory,
      tags: updateData.tags,
      notes: updateData.notes,
    };

    return await Card.findOneAndUpdate(
      { _id: cardId, ownerId: userId, isProfileCard: false },
      { ...allowedUpdates, updatedAt: new Date() },
      { new: true, runValidators: true }
    );
  }

  /**
   * Delete a collected card (soft delete)
   * @param {string} cardId - Card ID
   * @param {string} userId - User ID (for ownership check)
   * @returns {Promise<Card|null>} Deleted card
   */
  async deleteCollectedCard(cardId, userId) {
    return await Card.findOneAndUpdate(
      { _id: cardId, ownerId: userId, isProfileCard: false },
      {
        isActive: false,
        deletedAt: new Date(),
      },
      { new: true }
    );
  }

  /**
   * Check if user already has this card (by email)
   * Prevents duplicate collected cards
   * @param {string} userId - User ID
   * @param {string} email - Card email
   * @returns {Promise<boolean>} True if card exists
   */
  async hasCollectedCardByEmail(userId, email) {
    const count = await Card.countDocuments({
      ownerId: userId,
      isProfileCard: false,
      email: email.toLowerCase(),
      isActive: true,
    });
    return count > 0;
  }

  // ==================== STATISTICS ====================
  
  /**
   * Get card statistics for a user
   * @param {string} userId - User ID
   * @returns {Promise<Object>} Statistics
   */
  async getCardStats(userId) {
    const total = await Card.countDocuments({
      ownerId: userId,
      isProfileCard: false,
      isActive: true,
    });

    const byCategory = await Card.aggregate([
      {
        $match: {
          ownerId: userId,
          isProfileCard: false,
          isActive: true,
        },
      },
      {
        $group: {
          _id: '$customCategory',
          count: { $sum: 1 },
        },
      },
    ]);

    const categoryMap = {};
    byCategory.forEach(item => {
      const category = item._id || 'Uncategorized';
      categoryMap[category] = item.count;
    });

    return {
      total,
      byCategory: categoryMap,
    };
  }
}

module.exports = new CardRepository(); // Export singleton
