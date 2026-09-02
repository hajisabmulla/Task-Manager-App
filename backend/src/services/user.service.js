const userRepository = require('../repositories/user.repository');
const { AppError } = require('../utils/app-error');

class UserService {
  async getTeamMembers() {
    const users = await userRepository.findAll();
    return users.map((u) => ({
      id: u.id,
      name: u.name,
      email: u.email,
      createdAt: u.created_at,
    }));
  }

  async getUserById(id) {
    const user = await userRepository.findById(id);
    if (!user) {
      throw AppError.notFound('User not found', 'USER_NOT_FOUND');
    }
    return user;
  }
}

module.exports = new UserService();
