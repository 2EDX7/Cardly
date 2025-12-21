const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { authenticate } = require('../middleware/auth.middleware');

/**
 * User routes
 */

/**
 * @route   PATCH /api/users/preferences
 * @desc    Update user preferences (theme, language)
 * @access  Private
 */
router.patch('/preferences', authenticate, authController.updatePreferences);

module.exports = router;
