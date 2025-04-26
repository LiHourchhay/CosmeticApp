const User = require('../models/user');
const Role = require('../models/role');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'your-fallback-secret';

// Get all users with their roles' name, description, and permissions
exports.getUsers = async (req, res) => {
  try {
    const users = await User.find().populate('role', 'name description permissions');
    res.json(users);
  } catch (err) {
    console.error('Error fetching users:', err);
    res.status(500).json({ message: err.message });
  }
};

// Create a new user (registration)
exports.registerUser = async (req, res) => {
  const { username, email, password, role } = req.body;

  // Check if the username is already in use
  if (await User.findOne({ username })) {
    return res.status(400).json({ message: 'Username already in use' });
  }

  // Check if the email is already in use
  if (await User.findOne({ email })) {
    return res.status(400).json({ message: 'Email already in use' });
  }

  // Check if the password is provided
  if (!password) {
    return res.status(400).json({ message: 'Password is required' });
  }

  // Hash the password
  const hashedPassword = await bcrypt.hash(password, 10);

  // If no role is provided, set a default role (e.g., 'user')
  const userRole = role
    ? await Role.findOne({ name: role }) // Find role by name if provided
    : await Role.findOne({ name: 'user' }); // Default to 'user' role if no role provided

  if (!userRole) {
    return res.status(400).json({ message: 'Invalid role' });
  }

  // Create a new user with hashed password and assigned role
  const newUser = new User({ username, email, password: hashedPassword, role: userRole._id });

  try {
    await newUser.save();
    res.status(201).json({ message: 'User created successfully', user: newUser });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// Login the user
exports.login = async (req, res) => {
  const { username, email, password } = req.body;

  if (!username && !email) {
    return res.status(400).json({ message: 'Username or email is required' });
  }

  try {
    const user = await User.findOne({
      $or: [{ email }, { username }]
    }).populate('role', 'name permissions');

    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign(
      {
        sub: user._id.toString(),
        role: user.role.name,
        permissions: user.role.permissions,
      },
      JWT_SECRET,
      { expiresIn: '8h' }
    );

    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        role: user.role.name,
      },
    });
  } catch (err) {
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Update user details
exports.updateUser = async (req, res) => {
  const { username, email, password, role } = req.body;

  try {
    const user = await User.findById(req.params.id).populate('role');
    if (!user) return res.status(404).json({ message: 'User not found' });

    // Update fields if provided
    user.username = username || user.username;
    user.email = email || user.email;

    // If role is provided, update it (ensure role exists)
    if (role) {
      const updatedRole = await Role.findById(role);
      if (!updatedRole) {
        return res.status(400).json({ message: 'Invalid role' });
      }
      user.role = updatedRole._id;
    }

    // If password is updated, hash the new password
    if (password) {
      user.password = await bcrypt.hash(password, 10);
    }

    await user.save();
    res.json({ message: 'User updated successfully', user });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Delete a user
exports.deleteUser = async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json({ message: 'User deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
