const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
// Using environment variables (recommended for security)
try {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    }),
  });
  console.log('✅ Firebase Admin SDK initialized');
} catch (error) {
  console.error('❌ Failed to initialize Firebase Admin SDK:', error.message);
}

/**
 * Send push notification to user's device(s)
 * @param {Array<string>} tokens - FCM tokens
 * @param {Object} notification - {title, body}
 * @param {Object} data - Additional data payload
 */
async function sendNotification(tokens, notification, data = {}) {
  if (!tokens || tokens.length === 0) {
    console.log('⚠️ No FCM tokens to send to');
    return { successCount: 0, failureCount: 0 };
  }

  // Filter out invalid tokens
  const validTokens = tokens.filter(token => token && token.trim().length > 0);
  
  if (validTokens.length === 0) {
    console.log('⚠️ No valid FCM tokens');
    return { successCount: 0, failureCount: 0 };
  }

  const message = {
    notification: {
      title: notification.title,
      body: notification.body,
    },
    data: {
      ...data,
      // Convert all data values to strings (FCM requirement)
      timestamp: Date.now().toString(),
    },
    tokens: validTokens,
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    
    console.log(`📤 Sent ${response.successCount} notifications, ${response.failureCount} failed`);
    
    // Log failures for debugging
    if (response.failureCount > 0) {
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          console.error(`❌ Failed to send to token ${idx}: ${resp.error?.message}`);
        }
      });
    }
    
    return {
      successCount: response.successCount,
      failureCount: response.failureCount,
    };
  } catch (error) {
    console.error('❌ FCM send error:', error.message);
    throw error;
  }
}

/**
 * Send notification to a single user by their user ID
 * @param {string} userId - User ID
 * @param {Object} notification - {title, body}
 * @param {Object} data - Additional data payload
 */
async function sendNotificationToUser(userId, notification, data = {}) {
  const User = require('../models/User');
  
  try {
    const user = await User.findById(userId).select('fcmTokens preferences');
    
    if (!user) {
      console.log(`⚠️ User ${userId} not found`);
      return { successCount: 0, failureCount: 0 };
    }
    
    // Check if user has enabled notifications
    if (user.preferences?.receiveNotifications === false) {
      console.log(`⚠️ User ${userId} has disabled notifications`);
      return { successCount: 0, failureCount: 0 };
    }
    
    if (!user.fcmTokens || user.fcmTokens.length === 0) {
      console.log(`⚠️ No FCM tokens found for user ${userId}`);
      return { successCount: 0, failureCount: 0 };
    }

    return await sendNotification(user.fcmTokens, notification, data);
  } catch (error) {
    console.error(`❌ Failed to send notification to user ${userId}:`, error.message);
    throw error;
  }
}

module.exports = {
  sendNotification,
  sendNotificationToUser,
};
