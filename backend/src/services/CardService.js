const CardRepository = require('../repositories/CardRepository');
const { generateUniqueShareableId } = require('../utils/idGenerator.util');

/**
 * Service layer for card business logic
 * Handles both profile cards and collected cards
 */
class CardService {
  // ==================== PROFILE CARD METHODS ====================
  
  /**
   * Get user's profile card
   * @param {string} userId - User ID
   * @returns {Promise<Object|null>} Profile card or null
   */
  async getProfileCard(userId) {
    const card = await CardRepository.findProfileCard(userId);
    return card ? card.toObject() : null;
  }

  /**
   * Create or update user's profile card
   * @param {string} userId - User ID
   * @param {Object} cardData - Card data
   * @returns {Promise<Object>} Profile card
   */
  async upsertProfileCard(userId, cardData) {
    // Check if profile card already exists
    const existingCard = await CardRepository.findProfileCard(userId);

    if (existingCard) {
      // Update existing profile card
      // CRITICAL: shareableId is NEVER updated - it's immutable
      const updated = await CardRepository.updateProfileCard(userId, cardData);
      return updated.toObject();
    } else {
      // Create new profile card with shareable ID
      const shareableId = await generateUniqueShareableId(
        (id) => CardRepository.shareableIdExists(id)
      );

      const newCard = await CardRepository.createProfileCard(userId, {
        ...cardData,
        shareableId,
        isPublic: cardData.isPublic !== undefined ? cardData.isPublic : true,
      });

      return newCard.toObject();
    }
  }

  /**
   * Get a public profile card by shareable ID
   * Used for QR code scanning and ID-based sharing
   * @param {string} shareableId - Shareable ID
   * @returns {Promise<Object>} Profile card
   */
  async getProfileCardByShareableId(shareableId) {
    const card = await CardRepository.findByShareableId(shareableId);
    
    if (!card) {
      throw new Error('Card not found or not public');
    }

    return card.toObject();
  }

  // ==================== COLLECTED CARD METHODS ====================
  
  /**
   * Get all collected cards for a user
   * @param {string} userId - User ID
   * @param {Object} filters - Optional filters
   * @returns {Promise<Object>} Cards and pagination info
   */
  async getCollectedCards(userId, filters = {}) {
    const cards = await CardRepository.findCollectedCards(userId, filters);
    const total = await CardRepository.countCollectedCards(userId, filters);

    return {
      cards: cards.map(c => {
        const obj = c.toObject();
        // If this collected card has a source card with shareableId, use it
        if (c.sourceCardId && c.sourceCardId.shareableId) {
          obj.shareableId = c.sourceCardId.shareableId;
        }
        // Flatten sourceCardId back to string if it's an object (due to populate)
        if (obj.sourceCardId && typeof obj.sourceCardId === 'object') {
           obj.sourceCardId = obj.sourceCardId._id.toString();
        }
        return obj;
      }),
      pagination: {
        total,
        limit: filters.limit || 50,
        offset: filters.offset || 0,
      },
    };
  }

  /**
   * Get a specific collected card
   * @param {string} cardId - Card ID
   * @param {string} userId - User ID
   * @returns {Promise<Object>} Card
   */
  async getCollectedCard(cardId, userId) {
    const card = await CardRepository.findCollectedCardById(cardId, userId);
    
    if (!card) {
      throw new Error('Card not found');
    }

    const obj = card.toObject();
    if (card.sourceCardId && card.sourceCardId.shareableId) {
      obj.shareableId = card.sourceCardId.shareableId;
    }
    // Flatten sourceCardId back to string if it's an object
    if (obj.sourceCardId && typeof obj.sourceCardId === 'object') {
       obj.sourceCardId = obj.sourceCardId._id.toString();
    }
    return obj;
  }

  /**
   * Add a collected card manually
   * @param {string} userId - User ID
   * @param {Object} cardData - Card data
   * @returns {Promise<Object>} Created card
   */
  async addCollectedCard(userId, cardData) {
    // Check if user already has a card with this email
    const hasDuplicate = await CardRepository.hasCollectedCardByEmail(userId, cardData.email);
    
    if (hasDuplicate) {
      throw new Error('You already have a card with this email');
    }

    // Validate required fields
    if (!cardData.name || !cardData.email) {
      throw new Error('Name and email are required');
    }

    const card = await CardRepository.addCollectedCard(userId, cardData);
    return card.toObject();
  }

  /**
   * Collect a card via shareable ID (QR code or manual entry)
   * IMPORTANT: This creates a COPY of the profile card, not a reference
   * The shareableId belongs to the SOURCE card and is NEVER copied
   * @param {string} userId - User ID (collector)
   * @param {string} shareableId - Shareable ID to collect
   * @returns {Promise<Object>} Newly collected card
   */
  async collectCardByShareableId(userId, shareableId) {
    // Find the source profile card
    const sourceCard = await CardRepository.findByShareableId(shareableId);
    
    if (!sourceCard) {
      throw new Error('Card not found or not available for sharing');
    }

    // Check if user is trying to collect their own card
    if (sourceCard.ownerId.toString() === userId.toString()) {
      throw new Error('You cannot collect your own card');
    }

    // Check if user already has this card (by email to prevent duplicates)
    const hasDuplicate = await CardRepository.hasCollectedCardByEmail(userId, sourceCard.email);
    
    if (hasDuplicate) {
      throw new Error('You already have a card with this email');
    }

    // Create a COPY of the card for the collector
    // CRITICAL: The shareableId stays with the original owner
    // We create a new card WITHOUT shareableId
    const collectedCardData = {
      name: sourceCard.name,
      organization: sourceCard.organization,
      jobTitle: sourceCard.jobTitle,
      email: sourceCard.email,
      phone: sourceCard.phone,
      location: sourceCard.location,
      about: sourceCard.about,
      website: sourceCard.website,
      logoText: sourceCard.logoText,
      category: sourceCard.category,
      background: sourceCard.background,
      fontColor: sourceCard.fontColor,
      sourceCardId: sourceCard._id, // Optional: link to source for potential updates
      // NO shareableId - this is a collected card, not a profile card
      // NO isPublic - collected cards are private to the owner
    };

    const collectedCard = await CardRepository.addCollectedCard(userId, collectedCardData);
    
    return collectedCard.toObject();
  }

  /**
   * Update a collected card (only custom fields)
   * @param {string} cardId - Card ID
   * @param {string} userId - User ID
   * @param {Object} updateData - Data to update
   * @returns {Promise<Object>} Updated card
   */
  async updateCollectedCard(cardId, userId, updateData) {
    const card = await CardRepository.updateCollectedCard(cardId, userId, updateData);
    
    if (!card) {
      throw new Error('Card not found or update failed');
    }

    return card.toObject();
  }

  /**
   * Delete a collected card
   * @param {string} cardId - Card ID
   * @param {string} userId - User ID
   * @returns {Promise<Object>} Success message
   */
  async deleteCollectedCard(cardId, userId) {
    const card = await CardRepository.deleteCollectedCard(cardId, userId);
    
    if (!card) {
      throw new Error('Card not found or already deleted');
    }

    return { message: 'Card deleted successfully' };
  }

  // ==================== STATISTICS ====================
  
  /**
   * Get card statistics for a user
   * @param {string} userId - User ID
   * @returns {Promise<Object>} Statistics
   */
  async getCardStats(userId) {
    return await CardRepository.getCardStats(userId);
  }
}

module.exports = new CardService(); // Export singleton
