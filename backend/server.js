require('dotenv').config();
const app = require('./src/app');
const database = require('./src/config/database');

const PORT = process.env.PORT || 3000;

/**
 * Start the server
 */
async function start() {
  try {
    // Connect to MongoDB
    await database.connect();
    
    // Start Express server
    app.listen(PORT, () => {
      console.log('');
      console.log('╔═══════════════════════════════════════╗');
      console.log('║    🚀 Cardly Backend Server          ║');
      console.log('╚═══════════════════════════════════════╝');
      console.log('');
      console.log(`📡 Server running on port ${PORT}`);
      console.log(`🌐 Local: http://localhost:${PORT}`);
      console.log(`💚 Health: http://localhost:${PORT}/health`);
      console.log(`📚 API Info: http://localhost:${PORT}/api`);
      console.log(`📦 Database: ${database.getStatus()}`);
      console.log('');
      console.log('Press Ctrl+C to stop');
      console.log('');
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error.message);
    process.exit(1);
  }
}

// Handle graceful shutdown
process.on('SIGTERM', async () => {
  console.log('\\n🛑 SIGTERM received, closing server gracefully...');
  await database.disconnect();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('\\n🛑 SIGINT received, closing server gracefully...');
  await database.disconnect();
  process.exit(0);
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  console.error('❌ Uncaught Exception:', error);
  process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

// Start the server
start();
