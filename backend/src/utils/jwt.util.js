const jwt = require('jsonwebtoken');

/**
 * Utility functions for JWT token generation and verification
 */

const JWT_SECRET = process.env.JWT_SECRET || 'fallback-secret-change-in-production';
const JWT_EXPIRY = process.env.JWT_EXPIRY || '1h';

/**
 * Generate a JWT token for a user
 * @param {Object} payload - User data to encode (should not include sensitive info)
 * @returns {string} JWT token
 */
function generateToken(payload) {
  if (!payload || !payload.userId) {
    throw new Error('Payload must include userId');
  }
  
  // Create token with minimal payload
  const tokenPayload = {
    userId: payload.userId,
    email: payload.email,
  };
  
  return jwt.sign(tokenPayload, JWT_SECRET, {
    expiresIn: JWT_EXPIRY,
  });
}

/**
 * Verify and decode a JWT token
 * @param {string} token - JWT token to verify
 * @returns {Object} Decoded token payload
 * @throws {Error} If token is invalid or expired
 */
function verifyToken(token) {
  if (!token) {
    throw new Error('Token is required');
  }
  
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      throw new Error('Token has expired');
    }
    if (error.name === 'JsonWebTokenError') {
      throw new Error('Invalid token');
    }
    throw error;
  }
}

/**
 * Decode a JWT token without verifying (use with caution)
 * @param {string} token - JWT token to decode
 * @returns {Object|null} Decoded token payload or null if invalid
 */
function decodeToken(token) {
  try {
    return jwt.decode(token);
  } catch (error) {
    return null;
  }
}

/**
 * Extract token from Authorization header
 * @param {string} authHeader - Authorization header value
 * @returns {string|null} Token or null if not found
 */
function extractTokenFromHeader(authHeader) {
  if (!authHeader) {
    return null;
  }
  
  // Expected format: "Bearer <token>"
  const parts = authHeader.split(' ');
  
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return null;
  }
  
  return parts[1];
}

module.exports = {
  generateToken,
  verifyToken,
  decodeToken,
  extractTokenFromHeader,
};
