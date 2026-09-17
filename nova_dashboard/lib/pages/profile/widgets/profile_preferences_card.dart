// lib/pages/profile/widgets/profile_preferences_card.dart
// Conecta SettingsPage y HelpPage a la navegación (antes huérfanas).
import 'package:flutter/material.dart';
import '../profile_tokens.dart';
import '../settings_page.dart';
import '../help_page.dart';
import 'profile_shared.dart';

class ProfilePreferencesCard extends StatelessWidget {
  const ProfilePreferencesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Preferencias',
      child: Column(children: [
        profileActionRow(
          icon: Icons.settings_outlined,
          iconColor: kProfilePrimary,
          title: 'Configuración',
          subtitle: 'Preferencias de la aplicación',
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsPage())),
        ),
        profileRowDivider(),
        profileActionRow(
          icon: Icons.help_outline_rounded,
          iconColor: kProfilePrimary,
          title: 'Ayuda',
          subtitle: 'Preguntas frecuentes y soporte',
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HelpPage())),
        ),
      ]),
    );
  }
}
