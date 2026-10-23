// lib/pages/user_detail/widgets/user_profile_card.dart
// Extraído de user_detail_page.dart (_buildProfileCard/_badge) sin
// cambios de comportamiento ni de estilo.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../user_detail_tokens.dart';
import 'user_detail_shared.dart';

class UserProfileCard extends StatelessWidget {
  final UserModel user;
  const UserProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: userDetailCardDecoration(),
      child: Column(children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: user.isActive
              ? kUserDetailTeal.withOpacity(0.12)
              : AppTheme.border,
          child: Icon(
            user.isGoogleUser ? Icons.g_mobiledata : Icons.person,
            size: 34,
            color: user.isActive ? kUserDetailTeal : AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          user.displayName,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
              color: AppTheme.textHead),
          textAlign: TextAlign.center,
          maxLines: 2, overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        Text(
          user.email,
          style: const TextStyle(fontSize: 12, color: AppTheme.textBody),
          textAlign: TextAlign.center,
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 6, runSpacing: 6, alignment: WrapAlignment.center,
          children: [
            userDetailBadge(user.roleEmoji, user.roleLabel, kUserDetailTeal),
            userDetailBadge(
              user.isActive ? '✓' : '✗',
              user.isActive ? 'Activo' : 'Inactivo',
              user.isActive ? kUserDetailGreen : AppTheme.error,
            ),
          ],
        ),
        if (user.phone != null && user.phone!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGray,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(children: [
              const Icon(Icons.phone_rounded, size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 8),
              Expanded(child: Text(user.phone!,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textBody))),
            ]),
          ),
        ],
      ]),
    );
  }
}
