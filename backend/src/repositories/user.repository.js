const { query } = require('../config/database');

class UserRepository {
  async findByEmail(email) {
    const rows = await query('SELECT * FROM users WHERE email = ? LIMIT 1', [email]);
    return rows[0] || null;
  }

  async findById(id) {
    const rows = await query(
      'SELECT id, name, email, created_at, updated_at FROM users WHERE id = ? LIMIT 1',
      [id]
    );
    return rows[0] || null;
  }

  async create({ name, email, passwordHash }) {
    const result = await query(
      'INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)',
      [name, email, passwordHash]
    );
    return {
      id: result.insertId,
      name,
      email,
    };
  }

  async findAll() {
    const rows = await query(
      'SELECT id, name, email, created_at FROM users ORDER BY name ASC'
    );
    return rows;
  }
}

module.exports = new UserRepository();
