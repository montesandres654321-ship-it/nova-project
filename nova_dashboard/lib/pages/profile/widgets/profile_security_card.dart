// lib/pages/profile/widgets/profile_security_card.dart
// Extraído de profile_page.dart (_buildSecurityCard) sin cambios de
// comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../profile_tokens.dart';
import 'profile_shared.dart';

class ProfileSecurityCard extends StatelessWidget {
  final String userRole;
  final VoidCallback onChangePassword;

  const ProfileSecurityCard({
    super.key,
    required this.userRole,
    required this.onChangePassword,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Seguridad',
      child: Column(children: [
        profileActionRow(
          icon: Icons.lock_outlined,
          iconColor: kProfilePrimary,
          title: 'Cambiar contraseña',
          subtitle: 'Actualiza tu contraseña de acceso',
          onTap: onChangePassword,
        ),
        profileRowDivider(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: kProfileGreen.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kProfileGreen.withOpacity(0.18)),
          ),
          child: Row(children: [
            Container(
              width: 7, height: 7,
              decoration: const BoxDecoration(
                  color: kProfileGreen, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Conectado como ${AppConstants.getRoleLabel(userRole)}',
                style: const TextStyle(fontSize: 12,
                    color: kProfileGreen, fontWeight: FontWeight.w500),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
