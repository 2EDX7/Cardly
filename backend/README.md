# Cardly Backend

Backend API for the Cardly business card management application.

## Architecture

- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT with bcrypt password hashing
- **Architecture Pattern**: Clean Architecture with Repository Pattern

## Data Model

### Collections
1. **Users**: Authentication and user preferences
2. **Cards**: Unified collection for both:
   - Profile cards (user's own card with `isProfileCard: true`)
   - Collected cards (cards from others with `isProfileCard: false`)

## Getting Started

### Prerequisites
- Node.js (v14 or higher)
- MongoDB (running locally or MongoDB Atlas)

### Installation

```bash
# Install dependencies
npm install

# Copy environment template
cp env.example .env

# Edit .env and set your MongoDB URI
nano .env
```

### Running the Server

```bash
# Development mode (with auto-restart)
npm run dev

# Production mode
npm start
```

### Verify Installation

1. **Check health endpoint**:
```bash
curl http://localhost:3000/health
```

Expected response:
```json
{"status":"OK","message":"Cardly Backend is running","timestamp":"2025-..."}
```

2. **Check API info**:
```bash
curl http://localhost:3000/api
```

## Project Structure

```
backend/
├── src/
│   ├── models/          # Mongoose schemas
│   ├── repositories/    # Data access layer
│   ├── services/        # Business logic
│   ├── controllers/     # HTTP handlers
│   ├── routes/          # API routes
│   ├── middleware/      # Custom middleware
│   ├── utils/           # Utility functions
│   ├── config/          # Configuration
│   └── app.js           # Express app
├── tests/               # Test files
├── server.js            # Entry point
└── package.json
```

## Next Steps

- [ ] Implement authentication endpoints
- [ ] Implement card CRUD endpoints
- [ ] Add input validation
- [ ] Write tests
- [ ] Deploy to production

## License

ISC
