require('dotenv').config(); // ← ADD THIS at the top
const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const mongoHost = process.env.MONGO_URL;
    await mongoose.connect(`mongodb+srv://${mongoHost}.mongodb.net/test`);
    console.log('MongoDB connected');
  } catch (err) {
    console.error('MongoDB connection error:', err.message);
    process.exit(1);
  }
};

module.exports = connectDB;
