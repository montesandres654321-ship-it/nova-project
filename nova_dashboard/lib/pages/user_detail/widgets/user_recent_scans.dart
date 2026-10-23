// lib/pages/user_detail/widgets/user_recent_scans.dart
// Extraído de user_detail_page.dart (_buildRecentScans) sin cambios de
// comportamiento ni de estilo.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../user_detail_tokens.dart';
import 'user_detail_shared.dart';

class UserRecentScansCard extends StatelessWidget {
  final List<dynamic> scans;
  const UserRecentScansCard({super.key, required this.scans});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: userDetailCardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: userDetailSectionHeader('Últimos Escaneos', kUserDetailBlue),
        ),
        if (scans.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(child: Column(children: [
              const Icon(Icons.qr_code_scanner, size: 32, color: AppTheme.border),
              const SizedBox(height: 8),
              const Text('Sin escaneos registrados',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            ])),
          )
        else
          ...(scans.take(5).map((s) => ListTile(
            dense: true,
            leading: const Icon(Icons.qr_code_scanner, color: kUserDetailTeal, size: 20),
            title: Text(s['place_name'] ?? 'N/A',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            subtitle: Text('${s['tipo'] ?? ''} · ${s['lugar'] ?? ''}',
                style: const TextStyle(fontSize: 10, color: AppTheme.textBody)),
            trailing: Text(userDetailFormatDate(s['created_at']),
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          ))),
        const SizedBox(height: 8),
      ]),
    );
  }
}
