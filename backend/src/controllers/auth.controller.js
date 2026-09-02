const authService = require('../services/auth.service');
const { success } = require('../utils/api-response');
const { asyncHandler } = require('../utils/async-handler');

class AuthController {
  signup = asyncHandler(async (req, res) => {
    const result = await authService.signup(req.body);
    res.status(201).json(success(result, 'User registered successfully'));
  });

  login = asyncHandler(async (req, res) => {
    const result = await authService.login(req.body);
    res.status(200).json(success(result, 'Login successful'));
  });

  refresh = asyncHandler(async (req, res) => {
    const { refreshToken } = req.body;
    const result = await authService.refresh(refreshToken);
    res.status(200).json(success(result, 'Token refreshed successfully'));
  });

  logout = asyncHandler(async (req, res) => {
    const { refreshToken } = req.body;
    await authService.logout(refreshToken);
    res.status(200).json(success(null, 'Logged out successfully'));
  });
}

module.exports = new AuthController();
