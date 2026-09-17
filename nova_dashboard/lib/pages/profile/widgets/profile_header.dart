// lib/pages/profile/widgets/profile_header.dart
// Extraído de profile_page.dart (_buildProfileHeader) sin cambios de
// comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../profile_tokens.dart';
import 'profile_shared.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final words    = userName.trim().split(' ');
    final initials = words.length >= 2
        ? '${words.first[0]}${words.last[0]}'.toUpperCase()
        : userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: profileCardDecoration(),
      child: Column(children: [

        // Avatar con gradiente
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF06B6A4), Color(0xFF0891B2)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(
              color: kProfilePrimary.withOpacity(0.30),
              blurRadius: 16, offset: const Offset(0, 5),
            )],
          ),
          child: Center(
            child: Text(initials,
                style: const TextStyle(fontSize: 26,
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 14),

        // Nombre
        Text(
          userName.isNotEmpty ? userName : 'Usuario',
          style: const TextStyle(fontSize: 20,
              fontWeight: FontWeight.w800, color: kProfileTextHead),
          textAlign: TextAlign.center,
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        // Email
        Text(
          userEmail,
          style: const TextStyle(fontSize: 13, color: kProfileTextMuted),
          textAlign: TextAlign.center,
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 14),

        // Role badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: kProfilePrimary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kProfilePrimary.withOpacity(0.2)),
          ),
          child: Text(
            '${AppConstants.getRoleEmoji(userRole)} '
            '${AppConstants.getRoleLabel(userRole)}',
            style: const TextStyle(fontSize: 12,
                color: kProfilePrimary, fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }
}
