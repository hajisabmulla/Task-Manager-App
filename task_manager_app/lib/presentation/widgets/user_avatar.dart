import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';

class UserAvatar extends StatelessWidget {
  final UserModel? user;
  final double size;
  final double fontSize;

  const UserAvatar({
    super.key,
    required this.user,
    this.size = 32,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person_outline,
          size: size * 0.55,
          color: Colors.grey.shade500,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: user!.avatarColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: user!.avatarColor.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          user!.initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
