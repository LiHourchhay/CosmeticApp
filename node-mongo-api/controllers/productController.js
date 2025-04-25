const Product = require('../models/product');

// ✅ GET All Products
exports.getProducts = async (req, res) => {
  try {
    const products = await Product.find();
    res.status(200).json(products.map(product => ({ ...product.toObject(), id: product._id })));
  } catch (err) {
    res.status(500).json({ message: '❌ Error fetching products', error: err.message });
  }
};

// ✅ CREATE Product
exports.createProduct = async (req, res) => {
  const { name, brand, category, price, stock, description } = req.body;

  // Extract image paths
  const images = req.files ? req.files.map(file => file.path) : [];

  // Validate required fields
  if (!name || !brand || !category || !price || !stock || !description) {
    return res.status(400).json({ message: '❌ Missing required fields' });
  }

  try {
    const newProduct = new Product({
      name,
      brand,
      category,
      price,
      stock,
      description,
      images,
    });

    await newProduct.save();
    res.status(201).json({
      message: '✅ Product created successfully',
      product: { ...newProduct.toObject(), id: newProduct._id },
    });
  } catch (err) {
    res.status(400).json({ message: '❌ Failed to create product', error: err.message });
  }
};

// ✅ UPDATE Product
exports.updateProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ message: '❌ Product not found' });

    const { name, brand, category, price, stock, description } = req.body;
    const images = req.files ? req.files.map(file => file.path) : null;

    if (name) product.name = name;
    if (brand) product.brand = brand;
    if (category) product.category = category;
    if (price) product.price = price;
    if (stock) product.stock = stock;
    if (description) product.description = description;
    if (images) product.images = images;

    await product.save();
    res.json({
      message: '✅ Product updated successfully',
      product: { ...product.toObject(), id: product._id },
    });
  } catch (err) {
    res.status(500).json({ message: '❌ Failed to update product', error: err.message });
  }
};

// ✅ DELETE Product
exports.deleteProduct = async (req, res) => {
  try {
    const product = await Product.findByIdAndDelete(req.params.id);
    if (!product) return res.status(404).json({ message: '❌ Product not found' });

    res.json({ message: '✅ Product deleted successfully', id: product._id });
  } catch (err) {
    res.status(500).json({ message: '❌ Failed to delete product', error: err.message });
  }
};
