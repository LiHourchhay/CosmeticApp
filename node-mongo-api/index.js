const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const cors = require('cors');
const morgan = require('morgan');
const path = require('path');

// load .env
dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

// ── MIDDLEWARE ────────────────────────────────────────────────────────────────

// CORS
app.use(cors({
  origin: '*',
  methods: ['GET','POST','PUT','DELETE'],
  allowedHeaders: ['Content-Type','Authorization']
}));

// JSON body parsing
app.use(bodyParser.json());

// HTTP request logging
app.use(morgan('dev'));

// serve uploads folder
app.use('/uploads', express.static(path.join(__dirname,'uploads')));

// ensure uploads folder exists
const fs = require('fs');
const uploadPath = path.join(__dirname,'uploads');
if(!fs.existsSync(uploadPath)){
  fs.mkdirSync(uploadPath,{ recursive: true });
  console.log('📁 "uploads" folder created.');
}

// ── DATABASE ──────────────────────────────────────────────────────────────────

const connectDB = async() => {
  try{
    const dbURI = process.env.MONGODB_URI;
    if(!dbURI) throw new Error('MongoDB URI missing');
    await mongoose.connect(dbURI);
    console.log('✅ MongoDB connected');
  }catch(err){
    console.error('❌ DB Connection Error:',err.message);
    setTimeout(connectDB,5000);
  }
};

// ── ROUTES ────────────────────────────────────────────────────────────────────

const roleRoutes       = require('./routes/roleRoutes');
const userRoutes       = require('./routes/userRoutes');        // includes login, protected CRUD
const productRoutes    = require('./routes/productRoutes');

const apiRouter = express.Router();

// public routes (no auth)
apiRouter.use('/role', roleRoutes);

// userRoutes handles:
//   POST /api/user/login         ← login
//   then all /api/user/* protected
apiRouter.use('/user', userRoutes);

// productRoutes can be public or protected inside its own file
apiRouter.use('/product', productRoutes);

app.use('/api', apiRouter);

// ── GLOBAL ERROR HANDLER ──────────────────────────────────────────────────────

app.use((err,req,res,next)=>{
  console.error('❌',err);
  res.status(err.status||500).json({
    success: false,
    message: err.message||'Internal Server Error',
    error: process.env.NODE_ENV==='development'?err.stack:undefined
  });
});

// ── STARTUP ───────────────────────────────────────────────────────────────────

process.on('SIGINT',async()=>{
  console.log('🚨 Shutting down...');
  await mongoose.connection.close();
  process.exit(0);
});

connectDB().then(()=>{
  app.listen(port,()=>console.log(`🚀 Listening on http://localhost:${port}`));
});
