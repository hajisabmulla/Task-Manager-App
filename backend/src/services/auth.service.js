const bcrypt = require('bcrypt');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const userRepository = require('../repositories/user.repository');
const tokenRepository = require('../repositories/token.repository');
const { env } = require('../config/env');
const { AppError } = require('../utils/app-error');
const { AppConstants } = require('../config/constants');

class AuthService {
  async signup({ name, email, password }) {
    const existing = await userRepository.findByEmail(email);
    if (existing) {
      throw AppError.conflict('An account with this email address already exists', 'EMAIL_ALREADY_EXISTS');
    }

    const passwordHash = await bcrypt.hash(password, AppConstants.PASSWORD.SALT_ROUNDS);
    const user = await userRepository.create({ name, email, passwordHash });

    const tokens = await this._generateAuthTokens(user);
    return {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
      },
      ...tokens,
    };
  }

  async login({ email, password }) {
    const user = await userRepository.findByEmail(email);
    if (!user) {
      throw AppError.unauthorized('Invalid email or password', 'INVALID_CREDENTIALS');
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      throw AppError.unauthorized('Invalid email or password', 'INVALID_CREDENTIALS');
    }

    const tokens = await this._generateAuthTokens(user);
    return {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
      },
      ...tokens,
    };
  }

  async refresh(rawRefreshToken) {
    let decoded;
    try {
      decoded = jwt.verify(rawRefreshToken, env.JWT_REFRESH_SECRET);
    } catch (err) {
      if (err.name === 'TokenExpiredError') {
        throw AppError.unauthorized('Refresh token has expired. Please log in again.', 'REFRESH_TOKEN_EXPIRED');
      }
      throw AppError.unauthorized('Invalid refresh token.', 'REFRESH_TOKEN_INVALID');
    }

    const tokenHash = this._hashToken(rawRefreshToken);
    const storedToken = await tokenRepository.findByTokenHash(tokenHash);

    if (!storedToken) {
      throw AppError.unauthorized('Refresh token not found or already revoked.', 'REFRESH_TOKEN_NOT_FOUND');
    }

    if (storedToken.revoked_at) {
      // Possible token theft / reuse detected: revoke all tokens for safety
      await tokenRepository.revokeAllUserTokens(storedToken.user_id);
      throw AppError.unauthorized('Revoked refresh token reused. Session terminated for security.', 'REFRESH_TOKEN_REVOKED');
    }

    if (new Date(storedToken.expires_at) < new Date()) {
      await tokenRepository.revokeToken(tokenHash);
      throw AppError.unauthorized('Refresh token has expired.', 'REFRESH_TOKEN_EXPIRED');
    }

    const user = await userRepository.findById(decoded.id);
    if (!user) {
      throw AppError.unauthorized('User associated with this token no longer exists.', 'USER_NOT_FOUND');
    }

    // Revoke old refresh token (Token Rotation)
    await tokenRepository.revokeToken(tokenHash);

    // Issue new access & refresh tokens
    const tokens = await this._generateAuthTokens(user);
    return {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
      },
      ...tokens,
    };
  }

  async logout(rawRefreshToken) {
    if (!rawRefreshToken) return;

    try {
      const tokenHash = this._hashToken(rawRefreshToken);
      await tokenRepository.revokeToken(tokenHash);
    } catch (e) {
      // Ignore errors on logout
    }
  }

  async _generateAuthTokens(user) {
    const payload = {
      id: user.id,
      email: user.email,
      name: user.name,
      jti: crypto.randomUUID(),
    };

    const accessToken = jwt.sign(payload, env.JWT_ACCESS_SECRET, {
      expiresIn: env.JWT_ACCESS_EXPIRES_IN,
    });

    const refreshToken = jwt.sign(
      { ...payload, jti: crypto.randomUUID() },
      env.JWT_REFRESH_SECRET,
      { expiresIn: env.JWT_REFRESH_EXPIRES_IN }
    );

    // Compute expiry date for refresh token (default 7 days)
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    const tokenHash = this._hashToken(refreshToken);
    await tokenRepository.createToken({
      userId: user.id,
      tokenHash,
      expiresAt,
    });

    return {
      accessToken,
      refreshToken,
    };
  }

  _hashToken(token) {
    return crypto.createHash('sha256').update(token).digest('hex');
  }
}

module.exports = new AuthService();
