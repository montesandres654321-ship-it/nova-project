// lib/pages/owners/place_edit/place_edit_reward_section.dart
// Extraído de place_edit_page.dart (sección "🎁 Recompensa") sin cambios
// de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import 'place_edit_tokens.dart';

List<Widget> buildPlaceEditRewardSection({
  required bool hasReward,
  required void Function(bool) onHasRewardChanged,
  required String selectedRewardIcon,
  required List<Map<String, String>> rewardIcons,
  required void Function(String) onIconChanged,
  required TextEditingController rewardNameController,
  required TextEditingController rewardDescriptionController,
  required TextEditingController rewardStockController,
  required bool unlimitedStock,
  required void Function(bool) onUnlimitedStockChanged,
}) => [
  SwitchListTile(
    title: const Text('Recompensa activa',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    subtitle: Text(
        hasReward
            ? 'Los turistas ganan al escanear tu QR'
            : 'No se otorga recompensa',
        style: TextStyle(fontSize: 11, color: Colors.grey[600])),
    value: hasReward,
    onChanged: onHasRewardChanged,
    activeColor: kPlaceEditTeal,
    dense: true,
    contentPadding: EdgeInsets.zero,
  ),
  if (hasReward) ...[
    const Divider(height: 20),
    const Text('Ícono:',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    const SizedBox(height: 8),
    Wrap(spacing: 8, runSpacing: 8,
        children: rewardIcons.map((item) {
          final sel = selectedRewardIcon == item['icon'];
          return InkWell(
              onTap: () => onIconChanged(item['icon']!),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                      color: sel ? kPlaceEditAmber.withOpacity(0.12) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: sel ? kPlaceEditAmber : Colors.transparent,
                          width: 2)),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item['icon']!,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 2),
                        Text(item['label']!,
                            style: TextStyle(fontSize: 9,
                                color: sel ? kPlaceEditAmber : Colors.grey[600])),
                      ])));
        }).toList()),
    const SizedBox(height: 14),
    TextFormField(
      controller: rewardNameController,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
          labelText: 'Nombre de la recompensa *',
          hintText: 'Ej: Café gratis',
          prefixIcon: const Icon(Icons.card_giftcard_rounded, size: 18),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kPlaceEditTeal, width: 1.5))),
      validator: hasReward
          ? (v) => v?.trim().isEmpty ?? true
          ? 'El nombre es requerido' : null
          : null,
    ),
    const SizedBox(height: 12),
    TextFormField(
      controller: rewardDescriptionController,
      style: const TextStyle(fontSize: 13),
      maxLines: 2,
      decoration: InputDecoration(
          labelText: 'Descripción',
          hintText: 'Ej: 1 café americano mediano',
          prefixIcon: const Icon(Icons.info_outline_rounded, size: 18),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kPlaceEditTeal, width: 1.5))),
    ),
    const SizedBox(height: 14),
    Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Stock disponible',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(
                          unlimitedStock
                              ? 'Sin límite — todos pueden ganar'
                              : 'Cantidad máxima de recompensas',
                          style: TextStyle(fontSize: 10,
                              color: Colors.grey[600])),
                    ])),
                Switch(
                    value: unlimitedStock,
                    onChanged: onUnlimitedStockChanged,
                    activeColor: kPlaceEditTeal),
                Text(unlimitedStock ? 'Ilimitado' : 'Limitado',
                    style: TextStyle(fontSize: 11,
                        color: unlimitedStock ? kPlaceEditTeal : kPlaceEditAmber,
                        fontWeight: FontWeight.w600)),
              ]),
              if (!unlimitedStock) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: rewardStockController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                      labelText: 'Cantidad máxima',
                      hintText: 'Ej: 50',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.inventory_2_outlined),
                      suffixText: 'recompensas',
                      isDense: true,
                      fillColor: Colors.white,
                      filled: true),
                  validator: (v) {
                    if (unlimitedStock) return null;
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    if (int.tryParse(v.trim()) == null) return 'Debe ser número';
                    if (int.parse(v.trim()) < 0) return 'Debe ser positivo';
                    return null;
                  },
                ),
              ],
            ])),
  ] else ...[
    const SizedBox(height: 8),
    Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(children: [
        Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
        const SizedBox(width: 8),
        Expanded(child: Text(
          'Activa la recompensa para premiar a los turistas que escanean tu código QR.',
          style: TextStyle(fontSize: 11, color: Colors.orange[800]),
        )),
      ]),
    ),
  ],
];
