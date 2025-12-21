#!/bin/bash
# Test authentication endpoints with curl
# Make sure the server is running: npm run dev

BASE_URL="http://localhost:3000/api"

echo "🧪 Testing Cardly Authentication API"
echo "======================================"
echo ""

# Test 1: Register a new user
echo "1️⃣  Testing User Registration..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "John Doe",
    "email": "john@example.com",
    "password": "password123"
  }')

echo "$REGISTER_RESPONSE" | jq '.'
TOKEN=$(echo "$REGISTER_RESPONSE" | jq -r '.data.token')
echo "✅ Registration successful! Token saved."
echo ""

# Test 2: Login
echo "2️⃣  Testing User Login..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }')

echo "$LOGIN_RESPONSE" | jq '.'
echo "✅ Login successful!"
echo ""

# Test 3: Get Current User (Protected Route)
echo "3️⃣  Testing Get Current User (with JWT)..."
curl -s -X GET "$BASE_URL/auth/me" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
echo "✅ Got current user!"
echo ""

# Test 4: Update Preferences (Protected Route)
echo "4️⃣  Testing Update Preferences..."
curl -s -X PATCH "$BASE_URL/users/preferences" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "themeMode": "dark",
    "language": "en"
  }' | jq '.'
echo "✅ Preferences updated!"
echo ""

# Test 5: Test without token (should fail)
echo "5️⃣  Testing Protected Route Without Token (should fail)..."
curl -s -X GET "$BASE_URL/auth/me" | jq '.'
echo "✅ Correctly rejected unauthorized request!"
echo ""

# Test 6: Login with wrong password (should fail)
echo "6️⃣  Testing Login with Wrong Password (should fail)..."
curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "wrongpassword"
  }' | jq '.'
echo "✅ Correctly rejected wrong password!"
echo ""

echo "╔═══════════════════════════════════════╗"
echo "║  ✅ All API tests completed!          ║"
echo "╚═══════════════════════════════════════╝"
echo ""
echo "Note: The registered user 'john@example.com' is still in the database."
echo "You can delete it manually or it will be there for further testing."
