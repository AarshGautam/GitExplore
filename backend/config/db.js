const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const mongoHost = process.env.MONGO_HOST || 'localhost';
    await mongoose.connect(`mongodb://${mongoHost}:27017/CrudDB`);
    console.log('MongoDB connected');
  } catch (err) {
    console.error('MongoDB connection error:', err.message);
    process.exit(1);
  }
};

module.exports = connectDB;
