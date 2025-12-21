const CardService = require('../services/CardService');

/**
 * Controller for card endpoints
 * Handles HTTP requests and responses
 */

// ==================== PROFILE CARD CONTROLLERS ====================

/**
 * Get user's profile card
 * GET /api/profile-card
 */
async function getProfileCard(req, res) {
  try {
    const userId = req.user.userId;
    const card = await CardService.getProfileCard(userId);

    if (!card) {
      return res.status(404).json({
        success: false,
        message: 'Profile card not found',
      });
    }

    res.status(200).json({
      success: true,
      data: { profileCard: card },
    });
  } catch (error) {
    console.error('Get profile card error:', error.message);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
}

/**
 * Create or update user's profile card
 * PUT /api/profile-card
 */
async function upsertProfileCard(req, res) {
  try {
    const userId = req.user.userId;
    const cardData = req.body;

    const card = await CardService.upsertProfileCard(userId, cardData);

    res.status(200).json({
      success: true,
      data: { profileCard: card },
    });
  } catch (error) {
    console.error('Upsert profile card error:', error.message);
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
}

/**
 * Get public profile card by shareable ID
 * GET /api/profile-card/share/:shareableId
 */
async function getProfileCardByShareableId(req, res) {
  try {
    const { shareableId } = req.params;
    const card = await CardService.getProfileCardByShareableId(shareableId);

    res.status(200).json({
      success: true,
      data: { profileCard: card },
    });
  } catch (error) {
    console.error('Get profile card by shareable ID error:', error.message);
    res.status(404).json({
      success: false,
      message: error.message,
    });
  }
}

// ==================== COLLECTED CARD CONTROLLERS ====================

/**
 * Get all collected cards
 * GET /api/cards
 */
async function getCollectedCards(req, res) {
  try {
    const userId = req.user.userId;
    const filters = {
      category: req.query.category,
      search: req.query.search,
      limit: parseInt(req.query.limit) || 50,
      offset: parseInt(req.query.offset) || 0,
    };

    const result = await CardService.getCollectedCards(userId, filters);

    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    console.error('Get collected cards error:', error.message);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
}

/**
 * Get a specific collected card
 * GET /api/cards/:cardId
 */
async function getCollectedCard(req, res) {
  try {
    const userId = req.user.userId;
    const { cardId } = req.params;

    const card = await CardService.getCollectedCard(cardId, userId);

    res.status(200).json({
      success: true,
      data: { card },
    });
  } catch (error) {
    console.error('Get collected card error:', error.message);
    res.status(404).json({
      success: false,
      message: error.message,
    });
  }
}

/**
 * Add a collected card manually
 * POST /api/cards
 */
async function addCollectedCard(req, res) {
  try {
    const userId = req.user.userId;
    const cardData = req.body;

    const card = await CardService.addCollectedCard(userId, cardData);

    res.status(201).json({
      success: true,
      data: { card },
    });
  } catch (error) {
    console.error('Add collected card error:', error.message);
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
}

/**
 * Collect a card via shareable ID (QR code or manual entry)
 * POST /api/cards/collect/:shareableId
 */
async function collectCardByShareableId(req, res) {
  try {
    const userId = req.user.userId;
    const { shareableId } = req.params;

    const card = await CardService.collectCardByShareableId(userId, shareableId);

    res.status(201).json({
      success: true,
      data: { card },
      message: 'Card collected successfully',
    });
  } catch (error) {
    console.error('Collect card by shareable ID error:', error.message);
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
}

/**
 * Update a collected card
 * PUT /api/cards/:cardId
 */
async function updateCollectedCard(req, res) {
  try {
    const userId = req.user.userId;
    const { cardId } = req.params;
    const updateData = req.body;

    const card = await CardService.updateCollectedCard(cardId, userId, updateData);

    res.status(200).json({
      success: true,
      data: { card },
    });
  } catch (error) {
    console.error('Update collected card error:', error.message);
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
}

/**
 * Delete a collected card
 * DELETE /api/cards/:cardId
 */
async function deleteCollectedCard(req, res) {
  try {
    const userId = req.user.userId;
    const { cardId } = req.params;

    const result = await CardService.deleteCollectedCard(cardId, userId);

    res.status(200).json({
      success: true,
      message: result.message,
    });
  } catch (error) {
    console.error('Delete collected card error:', error.message);
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
}

/**
 * Get card statistics
 * GET /api/cards/stats
 */
async function getCardStats(req, res) {
  try {
    const userId = req.user.userId;
    const stats = await CardService.getCardStats(userId);

    res.status(200).json({
      success: true,
      data: stats,
    });
  } catch (error) {
    console.error('Get card stats error:', error.message);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
}

module.exports = {
  // Profile card
  getProfileCard,
  upsertProfileCard,
  getProfileCardByShareableId,
  
  // Collected cards
  getCollectedCards,
  getCollectedCard,
  addCollectedCard,
  collectCardByShareableId,
  updateCollectedCard,
  deleteCollectedCard,
  getCardStats,
};
