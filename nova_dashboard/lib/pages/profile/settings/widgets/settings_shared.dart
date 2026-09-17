// lib/pages/profile/settings/widgets/settings_shared.dart
// Extraído de settings_page.dart (_SettingsCard/_toggleRow/_dropdownRow/
// _dangerRow/_iconBox/_styledDropdown/_itemDivider) sin cambios de
// comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../settings_tokens.dart';

class SettingsCard extends StatelessWidget {
  final String       title;
  final List<Widget> children;
  const SettingsCard({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kSettingsBorder),
      boxShadow: [BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8, offset: const Offset(0, 2),
      )],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
        child: Text(title,
            style: const TextStyle(fontSize: 13,
                fontWeight: FontWeight.w700, color: kSettingsTextHead)),
      ),
      const Divider(height: 20, thickness: 0.5, color: kSettingsBorder),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        child: Column(children: children),
      ),
    ]),
  );
}

Widget settingsIconBox(IconData icon, Color color) => Container(
  width: 40, height: 40,
  decoration: BoxDecoration(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Icon(icon, size: 18, color: color),
);

Widget settingsToggleRow({
  required IconData         icon,
  required Color            iconColor,
  required String           title,
  required String           subtitle,
  required bool             value,
  required ValueChanged<bool> onChanged,
}) =>
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      settingsIconBox(icon, iconColor),
      const SizedBox(width: 14),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w600, color: kSettingsTextHead)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(fontSize: 11, color: kSettingsTextSub)),
        ],
      )),
      Transform.scale(
        scale: 0.85,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: kSettingsPrimary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    ]),
  );

Widget settingsDropdownRow({
  required IconData icon,
  required Color    iconColor,
  required String   title,
  required String   subtitle,
  required Widget   trailing,
}) =>
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      settingsIconBox(icon, iconColor),
      const SizedBox(width: 14),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w600, color: kSettingsTextHead)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(fontSize: 11, color: kSettingsTextSub)),
        ],
      )),
      trailing,
    ]),
  );

Widget settingsDangerRow({
  required IconData     icon,
  required String       title,
  required String       subtitle,
  required VoidCallback onTap,
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
            color: kSettingsRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: kSettingsRed),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w600, color: kSettingsRed)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11, color: kSettingsTextSub)),
          ],
        )),
        Icon(Icons.arrow_forward_ios_rounded, size: 13,
            color: kSettingsRed.withOpacity(0.4)),
      ]),
    ),
  );

Widget settingsStyledDropdown<T>({
  required T value,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
}) =>
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: kSettingsBgPage,
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: kSettingsBorder),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isDense: true,
        icon: const Icon(Icons.expand_more_rounded,
            size: 15, color: kSettingsTextMuted),
        style: const TextStyle(fontSize: 12, color: kSettingsTextHead),
        items: items,
        onChanged: onChanged,
      ),
    ),
  );

Widget settingsItemDivider() => const Padding(
  padding: EdgeInsets.symmetric(vertical: 2),
  child: Divider(height: 1, thickness: 0.5, color: kSettingsBorder),
);
