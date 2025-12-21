const mongoose = require('mongoose');

/**
 * Database connection singleton
 * Manages MongoDB connection lifecycle
 */
class Database {
  constructor() {
    this.connection = null;
  }

  /**
   * Connect to MongoDB
   * @returns {Promise<Connection>} Mongoose connection
   */
  async connect() {
    if (this.connection) {
      console.log('Using existing MongoDB connection');
      return this.connection;
    }

    try {
      this.connection = await mongoose.connect(process.env.MONGODB_URI, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
      });
      
      console.log('✅ MongoDB connected successfully');
      console.log(`📦 Database: ${mongoose.connection.name}`);
      
      return this.connection;
    } catch (error) {
      console.error('❌ MongoDB connection error:', error.message);
      throw error;
    }
  }

  /**
   * Disconnect from MongoDB
   */
  async disconnect() {
    if (this.connection) {
      await mongoose.disconnect();
      this.connection = null;
      console.log('MongoDB disconnected');
    }
  }

  /**
   * Get connection status
   * @returns {string} Connection state
   */
  getStatus() {
    const states = ['disconnected', 'connected', 'connecting', 'disconnecting'];
    return states[mongoose.connection.readyState];
  }
}

// Export singleton instance
module.exports = new Database();
