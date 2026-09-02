const { query } = require('../config/database');

class TokenRepository {
  async createToken({ userId, tokenHash, expiresAt }) {
    await query(
      'INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES (?, ?, ?)',
      [userId, tokenHash, expiresAt]
    );
  }

  async findByTokenHash(tokenHash) {
    const rows = await query(
      'SELECT * FROM refresh_tokens WHERE token_hash = ? LIMIT 1',
      [tokenHash]
    );
    return rows[0] || null;
  }

  async revokeToken(tokenHash) {
    await query(
      'UPDATE refresh_tokens SET revoked_at = CURRENT_TIMESTAMP WHERE token_hash = ?',
      [tokenHash]
    );
  }

  async revokeAllUserTokens(userId) {
    await query(
      'UPDATE refresh_tokens SET revoked_at = CURRENT_TIMESTAMP WHERE user_id = ? AND revoked_at IS NULL',
      [userId]
    );
  }
}

module.exports = new TokenRepository();
