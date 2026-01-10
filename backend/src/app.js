const express = require('express');
const cors = require('cors');

const app = express();

// Middleware
app.use(cors()); // Enable CORS for Flutter app
app.use(express.json()); // Parse JSON request bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies

// Request logging middleware (simple)
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'Cardly Backend is running',
    timestamp: new Date().toISOString(),
  });
});

// API info endpoint
app.get('/api', (req, res) => {
  res.json({
    name: 'Cardly API',
    version: '1.0.0',
    description: 'Backend API for Cardly business card management',
    endpoints: {
      health: '/health',
      auth: '/api/auth/*',
      users: '/api/users/*',
      cards: '/api/cards/*',
      profileCard: '/api/profile-card/*',
      sync: '/api/sync/*',
    },
  });
});

// Mount route handlers
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const cardRoutes = require('./routes/card.routes');
const notificationController = require('./controllers/notificationController');
const { authenticate } = require('./middleware/auth.middleware');

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api', cardRoutes); // Profile card and cards routes

// Notification routes
app.post('/api/notifications/register-token', authenticate, notificationController.registerToken);
app.post('/api/notifications/remove-token', authenticate, notificationController.removeToken);


// 404 handler - must be after all routes
app.use((req, res) => {
  res.status(404).json({ 
    success: false, 
    message: 'Route not found',
    path: req.path,
  });
});

// Global error handler - must be last
app.use((err, req, res, next) => {
  console.error('Error:', err.stack);
  
  res.status(err.status || 500).json({ 
    success: false, 
    message: err.message || 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.stack : undefined,
  });
});

module.exports = app;
