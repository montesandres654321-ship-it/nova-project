// lib/pages/places/form/place_form_layout.dart
// Extraído de form_page.dart (el LayoutBuilder responsive del body y el
// botón de guardar) sin cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import 'place_form_fields.dart';
import 'place_form_tokens.dart';

Widget placeFormBody({
  required List<Widget> infoBasica,
  required List<Widget> imagen,
  required List<Widget> detalles,
  required List<Widget> propietario,
  required List<Widget> recompensa,
  required bool loading,
  required bool uploadingImage,
  required bool isEditing,
  required VoidCallback onSave,
  required GlobalKey<FormState> formKey,
}) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Form(
          key: formKey,
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 900;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Columnas ──────────────────────────────
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Columna izquierda (60%)
                        Expanded(flex: 3, child: Column(
                          children: [
                            placeFormSectionCard('Información Básica', infoBasica),
                            const SizedBox(height: 16),
                            placeFormSectionCard('Imagen del Lugar', imagen),
                          ],
                        )),
                        const SizedBox(width: 16),
                        // Columna derecha (40%)
                        Expanded(flex: 2, child: Column(
                          children: [
                            placeFormSectionCard('Detalles', detalles),
                            const SizedBox(height: 16),
                            placeFormSectionCard('Propietario (Opcional)', propietario),
                          ],
                        )),
                      ],
                    )
                  else ...[
                    placeFormSectionCard('Información Básica', infoBasica),
                    const SizedBox(height: 16),
                    placeFormSectionCard('Imagen del Lugar', imagen),
                    const SizedBox(height: 16),
                    placeFormSectionCard('Detalles', detalles),
                    const SizedBox(height: 16),
                    placeFormSectionCard('Propietario (Opcional)', propietario),
                  ],

                  const SizedBox(height: 16),

                  // ── Recompensa (ancho completo) ───────────
                  placeFormSectionCard('🎁 Recompensa para Turistas', recompensa),

                  const SizedBox(height: 16),

                  // ── Botón guardar ──────────────────────────
                  Align(
                    alignment: isWide ? Alignment.centerRight : Alignment.center,
                    child: SizedBox(
                      width: isWide ? 220.0 : double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: (loading || uploadingImage) ? null : onSave,
                        icon: (loading || uploadingImage)
                            ? const SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save),
                        label: Text(
                            (loading || uploadingImage)
                                ? (uploadingImage
                                    ? 'Subiendo imagen...'
                                    : 'Guardando...')
                                : (isEditing ? 'Actualizar Lugar' : 'Crear Lugar'),
                            style: const TextStyle(fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kPlaceFormTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
