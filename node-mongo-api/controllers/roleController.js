const Role = require('../models/role');

// GET /api/role
exports.getRoles = async (req,res) => {
  try {
    const roles = await Role.find();
    res.json(roles);
  } catch(err) {
    res.status(500).json({ message: err.message });
  }
};

// POST /api/role
exports.createRole = async (req,res) => {
  const { name, description, permissions } = req.body;
  if (!name || !Array.isArray(permissions)){
    return res.status(400).json({ message:'Name and permissions array required' });
  }
  try {
    const role = new Role({ name, description, permissions });
    await role.save();
    res.status(201).json(role);
  } catch(err){
    res.status(400).json({ message: err.message });
  }
};

// PUT /api/role/:id
exports.updateRole = async (req,res) => {
  const { name, description, permissions } = req.body;
  try {
    const role = await Role.findById(req.params.id);
    if (!role) return res.status(404).json({ message:'Role not found' });
    if (name) role.name = name;
    if (description) role.description = description;
    if (Array.isArray(permissions)) role.permissions = permissions;
    await role.save();
    res.json(role);
  } catch(err) {
    res.status(500).json({ message: err.message });
  }
};

// DELETE /api/role/:id
exports.deleteRole = async (req,res) => {
  try {
    const role = await Role.findByIdAndDelete(req.params.id);
    if (!role) return res.status(404).json({ message:'Role not found' });
    res.json({ message:'Role deleted' });
  } catch(err){
    res.status(500).json({ message: err.message });
  }
};
