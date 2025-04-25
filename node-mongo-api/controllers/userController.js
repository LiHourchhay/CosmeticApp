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
exports.createUser = async (req, res) => {
  const { username, email, password, role } = req.body;

  // Check if the username is already in use
  if (await User.findOne({ username })) {
    console.log('Registration failed: Username already in use');
    return res.status(400).json({ message: 'Username already in use' });
  }

  // Check if the email is already in use
  if (await User.findOne({ email })) {
    console.log('Registration failed: Email already in use');
    return res.status(400).json({ message: 'Email already in use' });
  }

  // Check if the password is provided
  if (!password) {
    console.log('Registration failed: Password is required');
    return res.status(400).json({ message: 'Password is required' });
  }

  // Hash the password
  const hashedPassword = await bcrypt.hash(password, 10);
  console.log('Hashed password during registration:', hashedPassword);

  // Find the role from the roles collection
  const userRole = await Role.findById(role);
  if (!userRole) {
    console.log('Registration failed: Invalid role');
    return res.status(400).json({ message: 'Invalid role' });
  }

  // Create a new user with hashed password and assigned role
  const newUser = new User({ username, email, password: hashedPassword, role: userRole._id });

  try {
    await newUser.save();
    console.log('User registered successfully:', newUser);
    res.status(201).json({ message: 'User created successfully', user: newUser });
  } catch (err) {
    console.error('Error during registration:', err);
    res.status(400).json({ message: err.message });
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
        console.log('Update failed: Invalid role');
        return res.status(400).json({ message: 'Invalid role' });
      }
      user.role = updatedRole._id;
    }

    // If password is updated, hash the new password
    if (password) {
      user.password = await bcrypt.hash(password, 10);
      console.log('Updated hashed password:', user.password);
    }

    await user.save();
    console.log('User updated successfully:', user);
    res.json({ message: 'User updated successfully', user });
  } catch (err) {
    console.error('Error updating user:', err);
    res.status(500).json({ message: err.message });
  }
};

// Delete a user
exports.deleteUser = async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    console.log('User deleted successfully:', user);
    res.json({ message: 'User deleted successfully' });
  } catch (err) {
    console.error('Error deleting user:', err);
    res.status(500).json({ message: err.message });
  }
};

exports.login = async (req, res) => {
  const { username, email, password } = req.body;

  if (!username && !email) {
    console.log('Login failed: Username or email is required');
    return res.status(400).json({ message: 'Username or email is required' });
  }

  try {
    const user = await User.findOne({
      $or: [{ email }, { username }]
    }).populate('role', 'name permissions');

    if (!user) {
      console.log('Login failed: User not found');
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    console.log('User retrieved from database:', {
      id: user._id,
      username: user.username,
      email: user.email,
      hashedPassword: user.password,
      role: user.role ? user.role.name : 'No role assigned',
    });

    // Debug: Log the plain input password
    console.log('Input password during login:', password);

    // Debug: Log the hashed password from the database
    console.log('Hashed password from database:', user.password);

    // Verify the password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    console.log('Password comparison result:', isPasswordValid);

    if (!isPasswordValid) {
      console.log('Login failed: Password mismatch');
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

    console.log('Login successful: Token generated');

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
    console.error('Login error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
};