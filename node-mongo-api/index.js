const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const cors = require('cors');
const morgan = require('morgan');
const path = require('path');
const fs = require('fs');

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware setup
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(bodyParser.json());
app.use(morgan('dev'));

// Serve uploads folder
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Ensure uploads folder exists
const uploadPath = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadPath)) {
  fs.mkdirSync(uploadPath, { recursive: true });
  console.log('📁 "uploads" folder created.');
}

// Database connection
const connectDB = async () => {
  try {
    const dbURI = process.env.MONGODB_URI;
    if (!dbURI) throw new Error('MongoDB URI missing');
    await mongoose.connect(dbURI);
    console.log('✅ MongoDB connected');
  } catch (err) {
    console.error('❌ DB Connection Error:', err.message);
    setTimeout(connectDB, 5000);
  }
};

// Routes
const roleRoutes = require('./routes/roleRoutes');
const userRoutes = require('./routes/userRoutes');
const productRoutes = require('./routes/productRoutes');
const categoryRoutes = require('./routes/categoryRoutes');

const apiRouter = express.Router();

// Public routes
apiRouter.use('/role', roleRoutes);
apiRouter.use('/category', categoryRoutes);

// User routes, including registration and login
apiRouter.use('/user', userRoutes);

// Product routes
apiRouter.use('/product', productRoutes);

app.use('/api', apiRouter);

// Global error handler
app.use((err, req, res, next) => {
  console.error('❌', err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
    error: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
});

// Start server
process.on('SIGINT', async () => {
  console.log('🚨 Shutting down...');
  await mongoose.connection.close();
  process.exit(0);
});

connectDB().then(() => {
  app.listen(port, () => console.log(`🚀 Listening on http://localhost:${port}`));
});
