// lib/pages/profile/widgets/profile_shared.dart
// Extraído de profile_page.dart (_SectionCard/_infoRow/_actionRow/
// _rowDivider/_field/_dec/_cardDec) sin cambios de comportamiento ni de
// estilo.
import 'package:flutter/material.dart';
import '../profile_tokens.dart';

class ProfileSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const ProfileSectionCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: profileCardDecoration(),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
        child: Text(title,
            style: const TextStyle(fontSize: 13,
                fontWeight: FontWeight.w700, color: kProfileTextHead)),
      ),
      const Divider(height: 20, thickness: 0.5, color: kProfileBorder),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        child: child,
      ),
    ]),
  );
}

BoxDecoration profileCardDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: kProfileBorder),
  boxShadow: [BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 8, offset: const Offset(0, 2),
  )],
);

Widget profileInfoRow(IconData icon, String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 10),
  child: Row(children: [
    Icon(icon, size: 16, color: kProfileTextSub),
    const SizedBox(width: 12),
    Expanded(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: kProfileTextSub)),
        const SizedBox(height: 2),
        Text(
          value.isNotEmpty ? value : '—',
          style: const TextStyle(fontSize: 14,
              color: kProfileTextHead, fontWeight: FontWeight.w500),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
      ],
    )),
  ]),
);

Widget profileActionRow({
  required IconData     icon,
  required Color        iconColor,
  required String       title,
  required String       subtitle,
  required VoidCallback onTap,
  bool isDestructive = false,
}) =>
  InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 19, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: isDestructive ? kProfileRed : kProfileTextHead)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11, color: kProfileTextSub)),
          ],
        )),
        Icon(Icons.arrow_forward_ios_rounded, size: 13,
            color: isDestructive
                ? kProfileRed.withOpacity(0.4) : kProfileBorder),
      ]),
    ),
  );

Widget profileRowDivider() => const Padding(
  padding: EdgeInsets.symmetric(vertical: 2),
  child: Divider(height: 1, thickness: 0.5, color: kProfileBorder),
);

InputDecoration profileFieldDecoration(String label, IconData icon) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(fontSize: 13, color: kProfileTextSub),
  prefixIcon: Icon(icon, size: 17, color: kProfileTextSub),
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(
      horizontal: 12, vertical: 13),
  border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kProfileBorder)),
  enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kProfileBorder)),
  disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kProfileBorder)),
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kProfilePrimary, width: 1.5)),
  filled: true,
  fillColor: const Color(0xFFF8FAFC),
);

Widget profileField(String label, TextEditingController ctrl, IconData icon) =>
  TextField(
    controller: ctrl,
    enabled: true,
    style: const TextStyle(fontSize: 13),
    decoration: profileFieldDecoration(label, icon),
  );
