const mongoose = require('mongoose');

const roleSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true
  },
  description: String,
  
  permissions: {
    type: [String],
    required: true,
    default: []
  }
});

module.exports = mongoose.model('Role', roleSchema);
