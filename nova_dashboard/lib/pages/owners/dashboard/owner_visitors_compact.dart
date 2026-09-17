// lib/pages/owners/dashboard/owner_visitors_compact.dart
// Extraído de owners/dashboard_page.dart (_visitorsCompact) sin cambios
// de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_theme.dart';
import '../visitors_page.dart';

Widget ownerVisitorsCompact({
  required BuildContext context,
  required int? placeId,
  required List<Map<String, dynamic>> recentScans,
}) => Container(
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 6)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: Row(children: [
            Container(width: 3, height: 14, decoration: BoxDecoration(color: AppTheme.primaryDark, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 6),
            const Text('Últimos Visitantes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const Spacer(),
            InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OwnerVisitorsPage(placeId: placeId))),
              child: const Text('Ver todos →', style: TextStyle(fontSize: 10, color: AppTheme.primaryDark, fontWeight: FontWeight.w600)),
            ),
          ])),
      Expanded(child: recentScans.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.people_outline, size: 28, color: AppTheme.textMuted),
        SizedBox(height: AppTheme.space4),
        Text('Sin visitantes aún', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
      ]))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space8),
        itemCount: recentScans.length,
        itemBuilder: (_, i) {
          final s = recentScans[i];
          final n = '${s['first_name'] ?? ''} ${s['last_name'] ?? ''}'.trim();
          final d = (s['created_at'] ?? '').toString();
          String dl = ''; try { dl = DateFormat('d MMM, HH:mm', 'es').format(DateTime.parse(d)); } catch (_) { dl = d; }
          return ListTile(
            dense: true, visualDensity: const VisualDensity(vertical: -3),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
            leading: CircleAvatar(radius: 14, backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: Text(n.isNotEmpty ? n[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 10))),
            title: Text(n.isNotEmpty ? n : 'Turista',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            trailing: Text(dl, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
          );
        },
      )),
    ]));
