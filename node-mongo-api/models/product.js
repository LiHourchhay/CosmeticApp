const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: { type: String, required: true },
  brand: { type: String, required: true },
  category: { 
    type: mongoose.Schema.Types.ObjectId, // Reference to Category model
    ref: 'Category', // Name of the Category model
    required: true 
  },
  price: { type: Number, required: true },
  discountPrice: { type: Number },
  stock: { type: Number, required: true },
  description: { type: String, required: true },
  rating: { type: Number, default: 0 },
  images: [{ type: String }], 
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Product', productSchema);
