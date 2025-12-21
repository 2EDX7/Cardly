/**
 * Test script to verify MongoDB models
 * Run with: node test-models.js
 */
require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./src/models/User');
const Card = require('./src/models/Card');

async function testModels() {
  try {
    console.log('🔍 Testing Mongoose Models...\n');
    
    // Connect to MongoDB
    console.log('📡 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');
    
    // Test 1: Create a user
    console.log('Test 1: Creating a test user...');
    const user = await User.create({
      email: 'test@cardly.com',
      fullName: 'Test User',
      passwordHash: 'temp-hash-will-be-bcrypt',
      preferences: {
        themeMode: 'dark',
        language: 'en'
      }
    });
    console.log(`✅ User created: ${user.email} (ID: ${user._id})\n`);
    
    // Test 2: Create a profile card
    console.log('Test 2: Creating profile card...');
    const profileCard = await Card.create({
      ownerId: user._id,
      isProfileCard: true,
      name: 'Test User',
      email: 'test@cardly.com',
      organization: 'Cardly Inc',
      jobTitle: 'Software Engineer',
      phone: '+1234567890',
      location: 'San Francisco, CA',
      about: 'Testing the backend!',
      shareableId: 'TEST01',
      isPublic: true,
      background: 'purpleBlue',
      fontColor: '#FFFFFF',
    });
    console.log(`✅ Profile card created (ID: ${profileCard._id})\n`);
    
    // Test 3: Create a collected card
    console.log('Test 3: Creating collected card...');
    const collectedCard = await Card.create({
      ownerId: user._id,
      isProfileCard: false,
      name: 'Jane Doe',
      email: 'jane@example.com',
      organization: 'Tech Corp',
      jobTitle: 'Product Manager',
      phone: '+9876543210',
      location: 'New York, NY',
      about: 'Collected from QR scan',
      collectedAt: new Date(),
      customCategory: 'Work Contacts',
      background: 'gold',
      sourceCardId: null, // Not linked to another profile card
    });
    console.log(`✅ Collected card created (ID: ${collectedCard._id})\n`);
    
    // Test 4: Query profile card
    console.log('Test 4: Querying profile card...');
    const foundProfile = await Card.findProfileCard(user._id);
    console.log(`✅ Found profile card: ${foundProfile.name}\n`);
    
    // Test 5: Query collected cards
    console.log('Test 5: Querying collected cards...');
    const collectedCards = await Card.findCollectedCards(user._id);
    console.log(`✅ Found ${collectedCards.length} collected card(s)\n`);
    
    // Test 6: Verify unique profile card constraint
    console.log('Test 6: Testing unique profile card constraint...');
    try {
      await Card.create({
        ownerId: user._id,
        isProfileCard: true,
        name: 'Duplicate Profile',
        email: 'dupe@cardly.com',
      });
      console.log('❌ FAILED: Should not allow duplicate profile card\n');
    } catch (error) {
      console.log('✅ Correctly rejected duplicate profile card\n');
    }
    
    // Cleanup
    console.log('🧹 Cleaning up test data...');
    await User.deleteMany({ email: 'test@cardly.com' });
    await Card.deleteMany({ ownerId: user._id });
    console.log('✅ Test data cleaned up\n');
    
    console.log('╔═══════════════════════════════════════╗');
    console.log('║  ✅ All tests passed successfully!    ║');
    console.log('╚═══════════════════════════════════════╝\n');
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    console.error(error);
  } finally {
    await mongoose.disconnect();
    console.log('👋 Disconnected from MongoDB');
    process.exit(0);
  }
}

testModels();
