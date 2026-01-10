const mongoose = require('mongoose');
const admin = require('firebase-admin');
const User = require('../src/models/User');
require('dotenv').config();

// Initialize Firebase Admin SDK for this script
if (!admin.apps.length) {
  try {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n')
      })
    });
    console.log('✅ Firebase Admin SDK initialized');
  } catch (error) {
    console.error('❌ Failed to initialize Firebase:', error.message);
    console.log('\n⚠️  Make sure these env vars are set in .env:');
    console.log('  - FIREBASE_PROJECT_ID');
    console.log('  - FIREBASE_CLIENT_EMAIL');
    console.log('  - FIREBASE_PRIVATE_KEY');
    process.exit(1);
  }
}

async function sendNotification(tokens, notification, data = {}) {
  if (!tokens || tokens.length === 0) {
    console.log('No FCM tokens to send to');
    return;
  }

  // Filter out invalid tokens (basic validation)
  const validTokens = tokens.filter(token => 
    token && 
    typeof token === 'string' && 
    token.trim().length > 20 // FCM tokens are typically 140+ chars
  );

  if (validTokens.length === 0) {
    console.log('⚠️ No valid FCM tokens found');
    return { successCount: 0, failureCount: 0 };
  }

  if (validTokens.length < tokens.length) {
    console.log(`⚠️ Filtered out ${tokens.length - validTokens.length} invalid token(s)`);
  }

  const message = {
    notification: {
      title: notification.title,
      body: notification.body,
    },
    data: data,
    tokens: validTokens
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(`✅ Sent ${response.successCount} notifications, ${response.failureCount} failed`);
    
    if (response.failureCount > 0) {
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          console.error(`❌ Failed to send to token ${idx}:`, resp.error?.message || resp.error);
          if (resp.error?.code === 'messaging/registration-token-not-registered') {
            console.log(`   💡 Token ${idx} is expired/invalid - should be removed from database`);
          }
        }
      });
    }
    
    return response;
  } catch (error) {
    console.error('❌ FCM send error:', error);
    throw error;
  }
}

async function setupTestNotification() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Find the card owner (the user currently logged in the app)
    const cardOwner = await User.findOne({ email: 'chetouanezakaria4@gmail.com' });
    if (!cardOwner) {
      console.error('❌ Card owner not found!');
      process.exit(1);
    }
    console.log(`✅ Found card owner: ${cardOwner.fullName} (${cardOwner.email})`);

    // Check if the card owner has an FCM token
    if (!cardOwner.fcmTokens || cardOwner.fcmTokens.length === 0) {
      console.error('❌ Card owner has no FCM tokens registered!');
      console.log('Make sure you are logged into the Flutter app.');
      process.exit(1);
    }
    console.log(`✅ Card owner has ${cardOwner.fcmTokens.length} FCM token(s)`);

    // Find or create a test collector user using same email for both find and create
    const testCollectorEmail = 'benbouziane@example.com';
    let testCollector = await User.findOne({ email: testCollectorEmail });
    
    if (!testCollector) {
      const bcrypt = require('bcryptjs');
      const hashedPassword = await bcrypt.hash('testpass123', 10);
      
      try {
        testCollector = await User.create({
          email: testCollectorEmail,
          passwordHash: hashedPassword,
          fullName: 'Benbouziane Abdelhak',
          fcmTokens: []
        });
        console.log(`✅ Created test collector: ${testCollector.fullName}`);
      } catch (error) {
        // If creation fails due to duplicate, just find the existing one
        if (error.code === 11000) {
          testCollector = await User.findOne({ email: testCollectorEmail });
          console.log(`✅ Using existing test collector: ${testCollector.fullName}`);
        } else {
          throw error;
        }
      }
    } else {
      console.log(`✅ Using existing test collector: ${testCollector.fullName}`);
    }

    // Send test notification
    console.log('\n📤 Sending test notification...');
    await sendNotification(
      cardOwner.fcmTokens,
      {
        title: '🎉 Card Collected!',
        body: `Your card was saved by ${testCollector.fullName}`
      },
      {
        type: 'card_collected',
        collectorName: testCollector.fullName,
        timestamp: new Date().toISOString()
      }
    );

    console.log('\n✅ Test notification sent successfully!');
    console.log('📱 Check your device for the notification.');

    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

setupTestNotification();