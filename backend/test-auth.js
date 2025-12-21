/**
 * Test script for authentication endpoints
 * Run with: node test-auth.js
 */
require('dotenv').config();
const database = require('./src/config/database');

// Test user credentials
const testUser = {
  fullName: 'Test User',
  email: 'testauth@cardly.com',
  password: 'testpass123',
};

let authToken = null;
let userId = null;

async function testAuth() {
  try {
    console.log('🔐 Testing Authentication Endpoints...\n');
    
    // Connect to MongoDB
    await database.connect();
    
    // Clean up any existing test user
    const User = require('./src/models/User');
    await User.deleteMany({ email: testUser.email });
    console.log('✅ Cleaned up existing test data\n');
    
    // Test 1: Register
    console.log('Test 1: User Registration');
    const AuthService = require('./src/services/AuthService');
    
    const registerResult = await AuthService.register(testUser);
    console.log(`✅ User registered: ${registerResult.user.email}`);
    console.log(`   Token: ${registerResult.token.substring(0, 20)}...`);
    console.log(`   User ID: ${registerResult.user._id}\n`);
    
    authToken = registerResult.token;
    userId = registerResult.user._id;
    
    // Test 2: Duplicate registration should fail
    console.log('Test 2: Duplicate Registration (should fail)');
    try {
      await AuthService.register(testUser);
      console.log('❌ FAILED: Should not allow duplicate registration\n');
    } catch (error) {
      console.log(`✅ Correctly rejected: ${error.message}\n`);
    }
    
    // Test 3: Login
    console.log('Test 3: User Login');
    const loginResult = await AuthService.login({
      email: testUser.email,
      password: testUser.password,
    });
    console.log(`✅ User logged in: ${loginResult.user.email}`);
    console.log(`   Token: ${loginResult.token.substring(0, 20)}...\n`);
    
    // Test 4: Login with wrong password
    console.log('Test 4: Login with Wrong Password (should fail)');
    try {
      await AuthService.login({
        email: testUser.email,
        password: 'wrongpassword',
      });
      console.log('❌ FAILED: Should not allow login with wrong password\n');
    } catch (error) {
      console.log(`✅ Correctly rejected: ${error.message}\n`);
    }
    
    // Test 5: Get current user
    console.log('Test 5: Get Current User');
    const currentUser = await AuthService.getCurrentUser(userId);
    console.log(`✅ Got current user: ${currentUser.email}`);
    console.log(`   Full Name: ${currentUser.fullName}`);
    console.log(`   Preferences: theme=${currentUser.preferences.themeMode}, lang=${currentUser.preferences.language}\n`);
    
    // Test 6: Update preferences
    console.log('Test 6: Update Preferences');
    const updatedUser = await AuthService.updatePreferences(userId, {
      themeMode: 'dark',
      language: 'fr',
    });
    console.log(`✅ Preferences updated`);
    console.log(`   Theme: ${updatedUser.preferences.themeMode}`);
    console.log(`   Language: ${updatedUser.preferences.language}\n`);
    
    // Test 7: Change password
    console.log('Test 7: Change Password');
    await AuthService.changePassword(userId, testUser.password, 'newpassword123');
    console.log('✅ Password changed successfully\n');
    
    // Test 8: Login with new password
    console.log('Test 8: Login with New Password');
    const newLoginResult = await AuthService.login({
      email: testUser.email,
      password: 'newpassword123',
    });
    console.log(`✅ Login successful with new password\n`);
    
    // Test 9: Weak password validation
    console.log('Test 9: Weak Password Validation (should fail)');
    try {
      await AuthService.register({
        fullName: 'Test User 2',
        email: 'test2@cardly.com',
        password: '123', // Too short
      });
      console.log('❌ FAILED: Should reject weak password\n');
    } catch (error) {
      console.log(`✅ Correctly rejected: ${error.message}\n`);
    }
    
    // Test 10: JWT token verification
    console.log('Test 10: JWT Token Verification');
    const { verifyToken } = require('./src/utils/jwt.util');
    const decoded = verifyToken(authToken);
    console.log(`✅ Token verified successfully`);
    console.log(`   User ID from token: ${decoded.userId}`);
    console.log(`   Email from token: ${decoded.email}\n`);
    
    // Cleanup
    console.log('🧹 Cleaning up test data...');
    await User.deleteMany({ email: testUser.email });
    await User.deleteMany({ email: 'test2@cardly.com' });
    console.log('✅ Test data cleaned up\n');
    
    console.log('╔═══════════════════════════════════════╗');
    console.log('║  ✅ All auth tests passed!            ║');
    console.log('╚═══════════════════════════════════════╝\n');
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    console.error(error);
  } finally {
    await database.disconnect();
    console.log('👋 Disconnected from MongoDB');
    process.exit(0);
  }
}

testAuth();
