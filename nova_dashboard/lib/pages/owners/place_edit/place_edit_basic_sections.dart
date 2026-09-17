// lib/pages/owners/place_edit/place_edit_basic_sections.dart
// Extraído de place_edit_page.dart (secciones de Información, Descripción
// y Contacto) sin cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../../../models/place.dart';
import 'place_edit_fields.dart';

List<Widget> buildPlaceEditInfoSection(Place place) => [
  placeEditReadOnlyField('Nombre', place.name, Icons.business_rounded),
  const SizedBox(height: 10),
  Row(children: [
    Expanded(child: placeEditReadOnlyField(
        'Tipo', '${place.tipoEmoji} ${place.tipoLabel}',
        Icons.category_rounded)),
    const SizedBox(width: 12),
    Expanded(child: placeEditReadOnlyField(
        'Ubicación', place.lugar,
        Icons.location_on_rounded)),
  ]),
  const SizedBox(height: 8),
  Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blue[200]!)),
      child: Row(children: [
        Icon(Icons.info_outline, size: 14, color: Colors.blue[600]),
        const SizedBox(width: 6),
        Expanded(child: Text(
            'El nombre, tipo y ubicación solo puede cambiarlos el administrador.',
            style: TextStyle(fontSize: 11, color: Colors.blue[700]))),
      ])),
];

List<Widget> buildPlaceEditDescriptionSection({
  required TextEditingController descriptionController,
}) => [
  TextFormField(
    controller: descriptionController,
    maxLines: 4,
    style: const TextStyle(fontSize: 13),
    decoration: placeEditInputDecoration(
        'Descripción del lugar *', Icons.description_rounded),
    validator: (v) =>
    v?.trim().isEmpty ?? true ? 'La descripción es requerida' : null,
  ),
];

List<Widget> buildPlaceEditContactSection({
  required TextEditingController phoneController,
  required TextEditingController addressController,
}) => [
  TextFormField(
    controller: phoneController,
    keyboardType: TextInputType.phone,
    style: const TextStyle(fontSize: 13),
    decoration: placeEditInputDecoration('Teléfono', Icons.phone_rounded),
  ),
  const SizedBox(height: 12),
  TextFormField(
    controller: addressController,
    style: const TextStyle(fontSize: 13),
    decoration: placeEditInputDecoration('Dirección', Icons.home_rounded),
  ),
];
