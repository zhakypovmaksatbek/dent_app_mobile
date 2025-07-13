import 'package:dent_app_mobile/models/users/user_detail_model.dart';
import 'package:flutter/material.dart';

class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({super.key, required this.user});

  final UserDetailModel user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullName = [
      user.firstName ?? '',
      user.lastName ?? '',
    ].where((e) => e.isNotEmpty).join(' ');

    return Center(
      child: Column(
        children: [
          Hero(
            tag: 'profile_avatar_${user.id}',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                backgroundImage: _getProfileImage(),
                child:
                    _getProfileImage() == null
                        ? Icon(
                          Icons.person,
                          size: 50,
                          color: theme.primaryColor,
                        )
                        : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName.isNotEmpty ? fullName : 'User Name',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (user.email != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.email!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (user.doctorAvatar != "no image" && user.doctorAvatar != null) {
      return NetworkImage(user.doctorAvatar!);
    }
    return null;
  }
}
