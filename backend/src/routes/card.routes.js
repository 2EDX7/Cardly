const express = require('express');
const router = express.Router();
const cardController = require('../controllers/cardController');
const { authenticate, optionalAuthenticate } = require('../middleware/auth.middleware');

/**
 * Profile Card Routes
 * User's own business card
 */

/**
 * @route   GET /api/profile-card
 * @desc    Get user's profile card
 * @access  Private
 */
router.get('/profile-card', authenticate, cardController.getProfileCard);

/**
 * @route   PUT /api/profile-card
 * @desc    Create or update user's profile card
 * @access  Private
 */
router.put('/profile-card', authenticate, cardController.upsertProfileCard);

/**
 * @route   GET /api/profile-card/share/:shareableId
 * @desc    Get public profile card by shareable ID (for QR scanning)
 * @access  Public (but card must be public)
 */
router.get('/profile-card/share/:shareableId', cardController.getProfileCardByShareableId);

/**
 * Collected Cards Routes
 * Cards collected from others
 */

/**@route   GET /api/cards/stats
 * @desc    Get card statistics
 * @access  Private
 */
router.get('/cards/stats', authenticate, cardController.getCardStats);

/**
 * @route   GET /api/cards
 * @desc    Get all collected cards
 * @query   category, search, limit, offset
 * @access  Private
 */
router.get('/cards', authenticate, cardController.getCollectedCards);

/**
 * @route   POST /api/cards
 * @desc    Add a new collected card manually
 * @access  Private
 */
router.post('/cards', authenticate, cardController.addCollectedCard);

/**
 * @route   POST /api/cards/collect/:shareableId
 * @desc    Collect a card via shareable ID (QR code or manual entry)
 * @access  Private
 */
router.post('/cards/collect/:shareableId', authenticate, cardController.collectCardByShareableId);

/**
 * @route   GET /api/cards/:cardId
 * @desc    Get a specific collected card
 * @access  Private
 */
router.get('/cards/:cardId', authenticate, cardController.getCollectedCard);

/**
 * @route   PUT /api/cards/:cardId
 * @desc    Update a collected card (custom category, notes, tags)
 * @access  Private
 */
router.put('/cards/:cardId', authenticate, cardController.updateCollectedCard);

/**
 * @route   DELETE /api/cards/:cardId
 * @desc    Delete a collected card
 * @access  Private
 */
router.delete('/cards/:cardId', authenticate, cardController.deleteCollectedCard);

module.exports = router;
