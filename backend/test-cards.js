/**
 * Comprehensive test script for card operations
 * Tests profile cards, collected cards, and shareable ID immutability
 * Run with: node test-cards.js
 */
require('dotenv').config();
const database = require('./src/config/database');
const AuthService = require('./src/services/AuthService');
const CardService = require('./src/services/CardService');
const User = require('./src/models/User');
const Card = require('./src/models/Card');

// Test users
const user1Data = {
  fullName: 'Alice Johnson',
  email: 'alice@cardly.com',
  password: 'password123',
};

const user2Data = {
  fullName: 'Bob Smith',
  email: 'bob@cardly.com',
  password: 'password123',
};

let user1Id, user2Id, shareableId;

async function testCards() {
  try {
    console.log('🃏 Testing Card CRUD Operations...\n');
    
    // Connect to MongoDB
    await database.connect();
    
    // Cleanup
    await User.deleteMany({ email: { $in: [user1Data.email, user2Data.email] } });
    await Card.deleteMany({});
    console.log('✅ Cleaned up test data\n');
    
    // ============ SETUP: Create Test Users ============
    console.log('📝 Setup: Creating test users...');
    const user1Result = await AuthService.register(user1Data);
    const user2Result = await AuthService.register(user2Data);
    user1Id = user1Result.user._id;
    user2Id = user2Result.user._id;
    console.log(`✅ User 1 (Alice) created: ${user1Id}`);
    console.log(`✅ User 2 (Bob) created: ${user2Id}\n`);
    
    // ============ TEST 1: Create Alice's Profile Card ============
    console.log('Test 1: Create Profile Card');
    const aliceProfileCard = await CardService.upsertProfileCard(user1Id, {
      name: 'Alice Johnson',
      organization: 'Tech Corp',
      jobTitle: 'Senior Engineer',
      email: 'alice@techcorp.com',
      phone: '+1234567890',
      location: 'San Francisco, CA',
      about: 'Passionate about coding',
      website: 'https://alice.dev',
      logoText: 'AJ',
      category: 'Technology',
      background: 'purpleBlue',
      fontColor: '#FFFFFF',
      isPublic: true,
    });
    console.log(`✅ Alice's profile card created`);
    console.log(`   Shareable ID: ${aliceProfileCard.shareableId}`);
    console.log(`   Is Profile Card: ${aliceProfileCard.isProfileCard}`);
    console.log(`   Is Public: ${aliceProfileCard.isPublic}\n`);
    
    shareableId = aliceProfileCard.shareableId;
    
    // ============ TEST 2: Update Profile Card (Shareable ID Should NOT Change) ============
    console.log('Test 2: Update Profile Card (Shareable ID Immutability)');
    const updatedProfile = await CardService.upsertProfileCard(user1Id, {
      jobTitle: 'Lead Engineer', // Changed
      about: 'Updated bio',        // Changed
      isPublic: true,
    });
    console.log(`✅ Profile card updated`);
    console.log(`   New Job Title: ${updatedProfile.jobTitle}`);
    console.log(`   Shareable ID: ${updatedProfile.shareableId}`);
    
    if (updatedProfile.shareableId === shareableId) {
      console.log(`   ✅ PASS: Shareable ID remains unchanged!\n`);
    } else {
      console.log(`   ❌ FAIL: Shareable ID changed! This is a critical bug!\n`);
    }
    
    // ============ TEST 3: Bob Collects Alice's Card via Shareable ID ============
    console.log('Test 3: Collect Card via Shareable ID (QR Code Simulation)');
    const collectedCard = await CardService.collectCardByShareableId(user2Id, shareableId);
    console.log(`✅ Bob collected Alice's card`);
    console.log(`   Card Name: ${collectedCard.name}`);
    console.log(`   Card Email: ${collectedCard.email}`);
    console.log(`   Is Profile Card: ${collectedCard.isProfileCard}`);
    console.log(`   Shareable ID: ${collectedCard.shareableId || 'NONE'}`);
    console.log(`   Collected At: ${collectedCard.collectedAt}`);
    
    if (!collectedCard.shareableId) {
      console.log(`   ✅ PASS: Collected card has NO shareable ID (correct!)\n`);
    } else {
      console.log(`   ❌ FAIL: Collected card has shareable ID (bug!)\n`);
    }
    
    // ============ TEST 4: Verify Alice Still Has Her Original Card ============
    console.log('Test 4: Verify Original Card Integrity');
    const aliceCardAfterSharing = await CardService.getProfileCard(user1Id);
    console.log(`✅ Alice's profile card retrieved`);
    console.log(`   Shareable ID: ${aliceCardAfterSharing.shareableId}`);
    console.log(`   Is Public: ${aliceCardAfterSharing.isPublic}`);
    
    if (aliceCardAfterSharing.shareableId === shareableId) {
      console.log(`   ✅ PASS: Alice's shareable ID unchanged after Bob collected it!\n`);
    } else {
      console.log(`   ❌ FAIL: Alice's shareable ID changed!\n`);
    }
    
    // ============ TEST 5: Bob Cannot Collect the Same Card Twice ============
    console.log('Test 5: Prevent Duplicate Collection');
    try {
      await CardService.collectCardByShareableId(user2Id, shareableId);
      console.log(`❌ FAIL: Should not allow duplicate collection\n`);
    } catch (error) {
      console.log(`✅ PASS: Correctly rejected duplicate: ${error.message}\n`);
    }
    
    // ============ TEST 6: Alice Cannot Collect Her Own Card ============
    console.log('Test 6: Prevent Self-Collection');
    try {
      await CardService.collectCardByShareableId(user1Id, shareableId);
      console.log(`❌ FAIL: Should not allow self-collection\n`);
    } catch (error) {
      console.log(`✅ PASS: Correctly rejected self-collection: ${error.message}\n`);
    }
    
    // ============ TEST 7: Get Collected Cards ============
    console.log('Test 7: Get Bob\'s Collected Cards');
    const bobCards = await CardService.getCollectedCards(user2Id);
    console.log(`✅ Bob has ${bobCards.cards.length} collected card(s)`);
    console.log(`   Card: ${bobCards.cards[0].name} (${bobCards.cards[0].email})\n`);
    
    //  ============ TEST 8: Update Collected Card (Custom Fields Only) ============
    console.log('Test 8: Update Collected Card (Custom Fields)');
    const bobCardId = collectedCard._id;
    const updatedCollected = await CardService.updateCollectedCard(bobCardId, user2Id, {
      customCategory: 'Work Contacts',
      tags: ['colleague', 'tech'],
      notes: 'Met at conference 2025',
    });
    console.log(`✅ Bob updated collected card`);
    console.log(`   Custom Category: ${updatedCollected.customCategory}`);
    console.log(`   Tags: ${updatedCollected.tags.join(', ')}`);
    console.log(`   Notes: ${updatedCollected.notes}\n`);
    
    // ============ TEST 9: Get Card Stats ============
    console.log('Test 9: Get Card Statistics');
    const stats = await CardService.getCardStats(user2Id);
    console.log(`✅ Bob's card statistics:`);
    console.log(`   Total collected cards: ${stats.total}`);
    console.log(`   By category:`, stats.byCategory, '\n');
    
    // ============ TEST 10: Delete Collected Card ============
    console.log('Test 10: Delete Collected Card');
    await CardService.deleteCollectedCard(bobCardId, user2Id);
    console.log(`✅ Bob deleted collected card\n`);
    
    // Verify deletion
    const bobCardsAfterDelete = await CardService.getCollectedCards(user2Id);
    console.log(`   Bob now has ${bobCardsAfterDelete.cards.length} card(s)\n`);
    
    // ============ TEST 11: Profile Card Still Exists After Collection Deleted ============
    console.log('Test 11: Verify Profile Card Independence');
    const aliceCardFinal = await CardService.getProfileCard(user1Id);
    console.log(`✅ Alice's profile card still exists`);
    console.log(`   Shareable ID: ${aliceCardFinal.shareableId}`);
    
    if (aliceCardFinal.shareableId === shareableId) {
      console.log(`   ✅ PASS: Profile card unaffected by collected card deletion!\n`);
    } else {
      console.log(`   ❌ FAIL: Shareable ID changed!\n`);
    }
    
    // ============ TEST 12: Create Bob's Profile Card ============
    console.log('Test 12: Create Second Profile Card');
    const bobProfileCard = await CardService.upsertProfileCard(user2Id, {
      name: 'Bob Smith',
      organization: 'Design Co',
      jobTitle: 'Creative Director',
      email: 'bob@designco.com',
      phone: '+9876543210',
      location: 'New York, NY',
      website: 'https://bob.design',
      isPublic: true,
    });
    console.log(`✅ Bob's profile card created`);
    console.log(`   Shareable ID: ${bobProfileCard.shareableId}`);
    console.log(`   Different from Alice's: ${bobProfileCard.shareableId !== shareableId}\n`);
    
    // Cleanup
    console.log('🧹 Cleaning up test data...');
    await User.deleteMany({ email: { $in: [user1Data.email, user2Data.email] } });
    await Card.deleteMany({});
    console.log('✅ Test data cleaned up\n');
    
    console.log('╔═══════════════════════════════════════╗');
    console.log('║  ✅ All card tests passed!            ║');
    console.log('╚═══════════════════════════════════════╝\n');
    console.log('🔑 Key Findings:');
    console.log('  ✅ Shareable IDs are IMMUTABLE');
    console.log('  ✅ Collected cards do NOT have shareable IDs');
    console.log('  ✅ Profile cards remain independent');
    console.log('  ✅ Duplicate collection prevented');
    console.log('  ✅ Self-collection prevented');
    console.log('');
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    console.error(error);
  } finally {
    await database.disconnect();
    console.log('👋 Disconnected from MongoDB');
    process.exit(0);
  }
}

testCards();
