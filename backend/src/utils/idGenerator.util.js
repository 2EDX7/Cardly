/**
 * Utility to generate unique shareable IDs for profile cards
 * Format: 6 uppercase alphanumeric characters (e.g., "A1B2C3")
 */

const CHARSET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
const ID_LENGTH = 6;

/**
 * Generate a random shareable ID
 * @returns {string} 6-character alphanumeric ID
 */
function generateShareableId() {
  let id = '';
  for (let i = 0; i < ID_LENGTH; i++) {
    const randomIndex = Math.floor(Math.random() * CHARSET.length);
    id += CHARSET[randomIndex];
  }
  return id;
}

/**
 * Generate a unique shareable ID (checks database)
 * @param {Function} checkExists - Async function to check if ID exists
 * @param {number} maxAttempts - Maximum retry attempts
 * @returns {Promise<string>} Unique shareable ID
 */
async function generateUniqueShareableId(checkExists, maxAttempts = 10) {
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    const id = generateShareableId();
    const exists = await checkExists(id);
    
    if (!exists) {
      return id;
    }
  }
  
  throw new Error('Failed to generate unique shareable ID after maximum attempts');
}

/**
 * Validate shareable ID format
 * @param {string} id - ID to validate
 * @returns {boolean} True if valid format
 */
function isValidShareableId(id) {
  if (!id || typeof id !== 'string') {
    return false;
  }
  
  if (id.length !== ID_LENGTH) {
    return false;
  }
  
  // Check if all characters are in CHARSET
  for (let char of id.toUpperCase()) {
    if (!CHARSET.includes(char)) {
      return false;
    }
  }
  
  return true;
}

module.exports = {
  generateShareableId,
  generateUniqueShareableId,
  isValidShareableId,
  ID_LENGTH,
};
