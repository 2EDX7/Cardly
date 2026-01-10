const mongoose = require('mongoose');

/**
 * Unified Card model for both profile cards and collected cards
 * 
 * Profile Cards (isProfileCard: true):
 *   - Each user has exactly ONE profile card
 *   - Has shareableId for QR/link sharing
 *   - Displayed on user's profile page
 * 
 * Collected Cards (isProfileCard: false):
 *   - Multiple cards per user
 *   - Cards collected from other users or scanned
 *   - Can be organized with custom categories and tags
 */
const cardSchema = new mongoose.Schema({
  ownerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Owner ID is required'],
    index: true,
  },
  
  // KEY DIFFERENTIATOR: Profile card vs collected card
  isProfileCard: {
    type: Boolean,
    required: true,
    default: false,
    index: true,
  },
  
  // Card content fields
  name: {
    type: String,
    required: [true, 'Name is required'],
    trim: true,
  },
  organization: {
    type: String,
    default: '',
    trim: true,
  },
  jobTitle: {
    type: String,
    default: '',
    trim: true,
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    trim: true,
    lowercase: true,
  },
  phone: {
    type: String,
    default: '',
    trim: true,
  },
  location: {
    type: String,
    default: '',
    trim: true,
  },
  about: {
    type: String,
    default: '',
    trim: true,
  },
  website: {
    type: String,
    default: '',
    trim: true,
  },
  
  // Visual customization
  logoText: {
    type: String,
    default: '',
    trim: true,
    maxlength: [10, 'Logo text cannot exceed 10 characters'],
  },
  category: {
    type: String,
    default: 'Uncategorized',
    trim: true,
  },
  background: {
    type: String,
    default: 'defaultGradient',
    enum: [
      'defaultGradient', 'purple', 'gold', 'greenBlue', 'grey', 'blue', 
      'green', 'goldSilver', 'purpleBlue', 'orangePink', 'sunset',
      'primarySolid', 'secondarySolid', 'darkSolid', 'blueSolid', 'blackSolid'
    ],
  },
  fontColor: {
    type: String,
    default: '#FFFFFF',
    match: [/^#[0-9A-Fa-f]{6}$/, 'Font color must be a valid hex color'],
  },
  
  // Sharing fields (only relevant for profile cards)
  shareableId: {
    type: String,
    unique: true,
    sparse: true, // Only profile cards have this
    uppercase: true,
    match: [/^[A-Z0-9]{6}$/, 'Shareable ID must be 6 alphanumeric characters'],
  },
  isPublic: {
    type: Boolean,
    default: false,
  },
  
  // Source tracking (only for collected cards)
  sourceCardId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Card',
    default: null,
  },
  
  // Organization fields (for collected cards)
  customCategory: {
    type: String,
    default: null,
    trim: true,
  },
  tags: [{
    type: String,
    trim: true,
  }],
  notes: {
    type: String,
    default: '',
    trim: true,
  },
  
  // Timestamps
  collectedAt: {
    type: Date,
    default: null, // null for profile cards, populated for collected cards
  },
  lastSyncAt: {
    type: Date,
    default: null,
  },
  
  // Soft delete
  isActive: {
    type: Boolean,
    default: true,
  },
  deletedAt: {
    type: Date,
    default: null,
  },
}, {
  timestamps: true, // Automatically creates createdAt and updatedAt
});

// Compound indexes for efficient queries
cardSchema.index({ ownerId: 1, isProfileCard: 1 }); // Find user's profile card quickly
cardSchema.index({ ownerId: 1, email: 1 }); // Prevent duplicate collected cards
cardSchema.index({ shareableId: 1 }); // Fast QR code / shareable ID lookup
cardSchema.index({ ownerId: 1, customCategory: 1 }); // Category filtering
cardSchema.index({ ownerId: 1, createdAt: -1 }); // Chronological listing

// Pre-save middleware: Enforce one profile card per user
cardSchema.pre('save', async function(next) {
  // Only check if this is a profile card
  if (this.isProfileCard) {
    const existingProfileCard = await this.constructor.findOne({
      ownerId: this.ownerId,
      isProfileCard: true,
      _id: { $ne: this._id } // Exclude current document if updating
    });
    
    if (existingProfileCard) {
      const error = new Error('User already has a profile card');
      error.name = 'ValidationError';
      return next(error);
    }
  }
  next();
});

// Instance method: Check if card is a profile card
cardSchema.methods.isUserProfileCard = function() {
  return this.isProfileCard === true;
};

// Instance method: Check if card is active
cardSchema.methods.isCardActive = function() {
  return this.isActive && !this.deletedAt;
};

// Static method: Find user's profile card
cardSchema.statics.findProfileCard = function(userId) {
  return this.findOne({ ownerId: userId, isProfileCard: true, isActive: true });
};

// Static method: Find user's collected cards
cardSchema.statics.findCollectedCards = function(userId, filters = {}) {
  const query = { 
    ownerId: userId, 
    isProfileCard: false, 
    isActive: true,
    ...filters
  };
  return this.find(query).sort({ createdAt: -1 });
};

module.exports = mongoose.model('Card', cardSchema);
