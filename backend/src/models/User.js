const mongoose = require('mongoose');

/**
 * User model for authentication and preferences
 * Represents authenticated users in the Cardly app
 */
const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email'],
  },
  fullName: {
    type: String,
    required: [true, 'Full name is required'],
    trim: true,
    minlength: [2, 'Name must be at least 2 characters'],
  },
  passwordHash: {
    type: String,
    required: [true, 'Password hash is required'],
  },
  preferences: {
    themeMode: {
      type: String,
      enum: ['system', 'light', 'dark'],
      default: 'system',
    },
    language: {
      type: String,
      enum: ['en', 'fr', 'ar'],
      default: 'en',
    },
    receiveNotifications: {
      type: Boolean,
      default: true,
    },
  },
  fcmTokens: [{
    type: String,
  }],
  lastSyncAt: {
    type: Date,
    default: null,
  },
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

// Indexes
userSchema.index({ email: 1 }); // Fast email lookup
userSchema.index({ createdAt: -1 }); // Recent users first

// Instance method: Hide sensitive data in JSON responses
userSchema.methods.toJSON = function() {
  const obj = this.toObject();
  delete obj.passwordHash;
  delete obj.__v;
  return obj;
};

// Instance method: Check if user is active
userSchema.methods.isUserActive = function() {
  return this.isActive && !this.deletedAt;
};

module.exports = mongoose.model('User', userSchema);
