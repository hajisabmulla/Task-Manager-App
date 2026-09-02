const userService = require('../services/user.service');
const { success } = require('../utils/api-response');
const { asyncHandler } = require('../utils/async-handler');

class UserController {
  getTeamMembers = asyncHandler(async (req, res) => {
    const users = await userService.getTeamMembers();
    res.status(200).json(success(users, 'Team members retrieved successfully'));
  });
}

module.exports = new UserController();
