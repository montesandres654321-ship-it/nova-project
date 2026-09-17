// lib/pages/places/form/place_form_sections.dart
// Extraído de form_page.dart (_buildInfoBasica/_buildImagen/_buildDetalles/
// _buildRecompensa/_buildPropietario) sin cambios de comportamiento ni de
// estilo. Cada función recibe exactamente los valores/callbacks que necesita
// en vez de leerlos de campos privados de la página.
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../models/admin_model.dart';
import 'place_form_fields.dart';
import 'place_form_tokens.dart';

List<Widget> buildInfoBasicaSection({
  required TextEditingController nameController,
  required TextEditingController lugarController,
  required TextEditingController descriptionController,
  required String selectedType,
  required List<String> types,
  required void Function(String?) onTypeChanged,
}) => [
  placeFormResponsiveFieldRow(
    placeFormField(
        controller: nameController,
        label: 'Nombre del lugar',
        icon: Icons.business,
        validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null),
    placeFormTypeDropdown(
        value: selectedType,
        label: 'Tipo',
        icon: Icons.category,
        items: types,
        onChanged: onTypeChanged),
  ),
  const SizedBox(height: 12),
  placeFormField(
      controller: lugarController,
      label: 'Municipio / Lugar',
      icon: Icons.location_on,
      validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null),
  const SizedBox(height: 12),
  placeFormField(
      controller: descriptionController,
      label: 'Descripción',
      icon: Icons.description,
      maxLines: 2,
      validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null),
];

List<Widget> buildImagenSection({
  required TextEditingController imageUrlController,
  required PlatformFile? selectedImageFile,
  required bool uploadingImage,
  required VoidCallback onPickImage,
  required VoidCallback onClearImage,
}) => [
  placeFormResponsiveFieldRow(
    placeFormField(
        controller: imageUrlController,
        label: 'URL de imagen (opcional)',
        icon: Icons.link,
        hint: 'https://...'),
    OutlinedButton.icon(
        onPressed: uploadingImage ? null : onPickImage,
        icon: const Icon(Icons.upload_file),
        label: Text(selectedImageFile != null
            ? selectedImageFile.name
            : 'Subir desde archivo',
            overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: 12),
            side: const BorderSide(color: kPlaceFormTeal),
            foregroundColor: kPlaceFormTeal)),
  ),
  if (selectedImageFile != null) ...[
    const SizedBox(height: 8),
    Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green)),
        child: Row(children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(
              '${selectedImageFile.name} (${(selectedImageFile.size / 1024).toStringAsFixed(0)} KB)',
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis)),
          IconButton(
              icon: const Icon(Icons.close, color: Colors.red, size: 18),
              onPressed: onClearImage,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints()),
        ])),
  ],
];

List<Widget> buildDetallesSection({
  required TextEditingController addressController,
  required TextEditingController phoneController,
  required TextEditingController amenitiesController,
  required bool isActive,
  required void Function(bool) onActiveChanged,
}) => [
  placeFormResponsiveFieldRow(
    placeFormField(controller: addressController, label: 'Dirección', icon: Icons.home),
    placeFormField(controller: phoneController, label: 'Teléfono', icon: Icons.phone),
  ),
  const SizedBox(height: 12),
  placeFormField(
      controller: amenitiesController,
      label: 'Servicios (separados por coma)',
      icon: Icons.list,
      hint: 'Wifi, Piscina, A/C'),
  const SizedBox(height: 12),
  SwitchListTile(
    title: const Text('Lugar activo', style: TextStyle(fontSize: 13)),
    subtitle: Text(
        isActive ? 'Visible en la app' : 'Oculto',
        style: TextStyle(fontSize: 11, color: Colors.grey[600])),
    value: isActive,
    onChanged: onActiveChanged,
    activeColor: kPlaceFormTeal,
    dense: true,
    contentPadding: EdgeInsets.zero,
  ),
];

List<Widget> buildRecompensaSection({
  required bool hasReward,
  required void Function(bool) onHasRewardChanged,
  required String selectedRewardIcon,
  required List<Map<String, String>> rewardIcons,
  required void Function(String) onIconChanged,
  required TextEditingController rewardNameController,
  required TextEditingController rewardDescriptionController,
  required TextEditingController rewardStockController,
}) => [
  SwitchListTile(
    title: const Text('Recompensa activa',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    subtitle: Text(
        hasReward
            ? 'Los turistas ganan al escanear el QR'
            : 'No se otorga recompensa al escanear',
        style: TextStyle(fontSize: 11, color: Colors.grey[600])),
    value: hasReward,
    onChanged: onHasRewardChanged,
    activeColor: kPlaceFormTeal,
    dense: true,
    contentPadding: EdgeInsets.zero,
  ),
  if (hasReward) ...[
    const SizedBox(height: 12),
    const Text('Ícono de la recompensa:',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    const SizedBox(height: 8),
    Wrap(spacing: 8, runSpacing: 8,
        children: rewardIcons.map((item) {
          final sel = selectedRewardIcon == item['icon'];
          return InkWell(
              onTap: () => onIconChanged(item['icon']!),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: sel ? kPlaceFormTeal.withOpacity(0.15) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: sel ? kPlaceFormTeal : Colors.transparent,
                          width: 2)),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(item['icon']!,
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 2),
                    Text(item['label']!,
                        style: TextStyle(
                            fontSize: 9,
                            color: sel ? kPlaceFormTeal : Colors.grey[700])),
                  ])));
        }).toList()),
    const SizedBox(height: 14),
    placeFormResponsiveFieldRow(
      placeFormField(
          controller: rewardNameController,
          label: 'Nombre de la recompensa',
          icon: Icons.card_giftcard,
          hint: 'Ej: Café gratis',
          validator: hasReward
              ? (v) => v?.isEmpty ?? true ? 'Requerido' : null
              : null),
      placeFormField(
          controller: rewardDescriptionController,
          label: 'Descripción',
          icon: Icons.info_outline,
          hint: 'Ej: 1 café americano mediano'),
    ),
    const SizedBox(height: 12),
    TextFormField(
      controller: rewardStockController,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 13),
      decoration: placeFormInputDecoration(
        'Stock disponible (vacío = ilimitado)',
        Icons.inventory_2_outlined,
        hint: 'Ej: 50 — dejar vacío para sin límite',
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return null;
        if (int.tryParse(v.trim()) == null) return 'Debe ser un número';
        if (int.parse(v.trim()) < 0) return 'Debe ser positivo';
        return null;
      },
    ),
    const SizedBox(height: 4),
    Text('Vacío o 0 = sin límite de recompensas',
        style: TextStyle(fontSize: 10, color: Colors.grey[500])),
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
          'Activa la recompensa para que los turistas reciban un premio al escanear el código QR del establecimiento.',
          style: TextStyle(fontSize: 11, color: Colors.orange[800]),
        )),
      ]),
    ),
  ],
];

List<Widget> buildPropietarioSection({
  required bool loadingOwners,
  required int? selectedOwnerId,
  required List<AdminModel> availableOwners,
  required void Function(int?) onOwnerChanged,
}) => [
  loadingOwners
      ? const Center(child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(color: kPlaceFormTeal)))
      : DropdownButtonFormField<int>(
          value: selectedOwnerId,
          decoration: placeFormInputDecoration(
              'Asignar propietario',
              Icons.person,
              hint: 'Sin propietario (opcional)'),
          items: [
            const DropdownMenuItem<int>(
                value: null,
                child: Text('Sin propietario')),
            ...availableOwners.map((o) =>
                DropdownMenuItem<int>(
                    value: o.id,
                    child: Text(
                        '${o.displayName} — ${o.email}',
                        overflow: TextOverflow.ellipsis))),
          ],
          onChanged: onOwnerChanged),
];
