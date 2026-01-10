const mongoose = require('mongoose');
const admin = require('firebase-admin');
const User = require('../src/models/User');
const { sendNotificationToUser } = require('../src/services/fcmService');
require('dotenv').config();

// Initialize Firebase Admin SDK for this script
// Note: fcmService.js also initializes it, but we need to ensure it's done before we use it
if (!admin.apps.length) {
  try {
    const projectId = process.env.FIREBASE_PROJECT_ID;
    const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
    const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');

    if (!projectId || !clientEmail || !privateKey) {
      throw new Error('Missing Firebase environment variables');
    }

    admin.initializeApp({
      credential: admin.credential.cert({
        projectId,
        clientEmail,
        privateKey,
      })
    });
    console.log('✅ Firebase Admin SDK initialized');
  } catch (error) {
    console.error('❌ Failed to initialize Firebase Admin SDK:', error.message);
    console.log('\n⚠️  Make sure these env vars are set in .env:');
    console.log('  - FIREBASE_PROJECT_ID');
    console.log('  - FIREBASE_CLIENT_EMAIL');
    console.log('  - FIREBASE_PRIVATE_KEY');
    process.exit(1);
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

    // Check notification preferences
    const notificationsEnabled = cardOwner.preferences?.receiveNotifications !== false;
    console.log(`📬 Notifications enabled: ${notificationsEnabled}`);

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
    await sendNotificationToUser(
      cardOwner._id.toString(),
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
    if (!notificationsEnabled) {
      console.log('⚠️  Note: Notifications were disabled for this user, so nothing was sent.');
    }

    await mongoose.connection.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

setupTestNotification();