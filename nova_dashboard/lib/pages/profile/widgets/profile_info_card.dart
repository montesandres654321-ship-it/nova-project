// lib/pages/profile/widgets/profile_info_card.dart
// Extraído de profile_page.dart (_buildInfoCard/_displayInfo/_editForm)
// sin cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../profile_tokens.dart';
import 'profile_shared.dart';

class ProfileInfoCard extends StatelessWidget {
  final bool editing;
  final String userName;
  final String userEmail;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final VoidCallback onStartEdit;
  final VoidCallback onCancelEdit;
  final VoidCallback onSave;

  const ProfileInfoCard({
    super.key,
    required this.editing,
    required this.userName,
    required this.userEmail,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.onStartEdit,
    required this.onCancelEdit,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Información personal',
      child: editing ? _editForm() : _displayInfo(),
    );
  }

  Widget _displayInfo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      profileInfoRow(Icons.person_rounded, 'Nombre completo', userName),
      profileRowDivider(),
      profileInfoRow(Icons.email_outlined, 'Correo electrónico', userEmail),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: onStartEdit,
        icon: const Icon(Icons.edit_outlined, size: 15),
        label: const Text('Editar información',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        style: OutlinedButton.styleFrom(
          foregroundColor: kProfilePrimary,
          side: const BorderSide(color: kProfileBorder),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    ],
  );

  Widget _editForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Expanded(child: profileField('Nombre(s)', firstNameController,
            Icons.person_rounded)),
        const SizedBox(width: 12),
        Expanded(child: profileField('Apellido(s)', lastNameController,
            Icons.person_outline_rounded)),
      ]),
      const SizedBox(height: 12),
      TextField(
        controller: TextEditingController(text: userEmail),
        enabled: false,
        style: const TextStyle(fontSize: 13),
        decoration: profileFieldDecoration('Correo electrónico', Icons.email_rounded),
      ),
      const SizedBox(height: 12),
      profileField('Teléfono (opcional)', phoneController, Icons.phone_rounded),
      const SizedBox(height: 18),
      Row(children: [
        Expanded(child: OutlinedButton(
          onPressed: onCancelEdit,
          style: OutlinedButton.styleFrom(
            foregroundColor: kProfileTextMuted,
            side: const BorderSide(color: kProfileBorder),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('Cancelar',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        )),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: kProfilePrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('Guardar',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        )),
      ]),
    ],
  );
}
