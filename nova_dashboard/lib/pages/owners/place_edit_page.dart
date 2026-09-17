// lib/pages/owners/place_edit_page.dart
// ============================================================
// CAMBIOS vs versión anterior:
//   1. Nueva sección "🎁 Recompensa" con selector de ícono,
//      nombre, descripción, stock (ilimitado/limitado)
//   2. Al guardar, envía datos de recompensa junto con el resto
//      en una sola petición PATCH /places/my-place
//   3. Si el lugar ya tiene recompensa, los campos vienen prellenados
// REFACTOR: secciones y subida de imagen extraídas a
// lib/pages/owners/place_edit/ para bajar de 624 a <300 líneas.
// ============================================================
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/place.dart';
import '../../utils/constants.dart';
import 'place_edit/place_edit_basic_sections.dart';
import 'place_edit/place_edit_fields.dart';
import 'place_edit/place_edit_image_section.dart';
import 'place_edit/place_edit_image_upload.dart';
import 'place_edit/place_edit_reward_section.dart';
import 'place_edit/place_edit_tokens.dart';

class OwnerPlaceEditPage extends StatefulWidget {
  final Place place;
  final VoidCallback onSaved;

  const OwnerPlaceEditPage({
    super.key,
    required this.place,
    required this.onSaved,
  });

  @override
  State<OwnerPlaceEditPage> createState() => _OwnerPlaceEditPageState();
}

class _OwnerPlaceEditPageState extends State<OwnerPlaceEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _loading        = false;
  bool _uploadingImage = false;

  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _imageUrlController;

  // Controladores de recompensa
  late TextEditingController _rewardNameController;
  late TextEditingController _rewardDescriptionController;
  late TextEditingController _rewardStockController;
  late bool   _hasReward;
  late String  _selectedRewardIcon;
  bool _unlimitedStock = true;

  PlatformFile? _selectedImageFile;

  final List<Map<String, String>> _rewardIcons = [
    {'icon': '☕', 'label': 'Café'},
    {'icon': '🥤', 'label': 'Bebida'},
    {'icon': '🍔', 'label': 'Comida'},
    {'icon': '🍕', 'label': 'Pizza'},
    {'icon': '🍰', 'label': 'Postre'},
    {'icon': '🎁', 'label': 'Regalo'},
    {'icon': '💰', 'label': 'Descuento'},
    {'icon': '🎫', 'label': 'Cupón'},
    {'icon': '🍹', 'label': 'Coctel'},
    {'icon': '⛵', 'label': 'Tour'},
    {'icon': '💆', 'label': 'Spa'},
    {'icon': '🦐', 'label': 'Mariscos'},
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.place;
    _descriptionController = TextEditingController(text: p.description);
    _phoneController       = TextEditingController(text: p.phone ?? '');
    _addressController     = TextEditingController(text: p.address ?? '');
    _imageUrlController    = TextEditingController(text: p.imageUrl ?? '');

    // Recompensa
    _hasReward             = p.hasReward;
    _selectedRewardIcon    = p.rewardIcon ?? '🎁';
    _rewardNameController  = TextEditingController(text: p.rewardName ?? '');
    _rewardDescriptionController = TextEditingController(text: p.rewardDescription ?? '');
    _unlimitedStock        = p.rewardStock == null;
    _rewardStockController = TextEditingController(
        text: p.rewardStock?.toString() ?? '');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _imageUrlController.dispose();
    _rewardNameController.dispose();
    _rewardDescriptionController.dispose();
    _rewardStockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await pickOwnerPlaceImage(onError: _showError);
    if (file != null) setState(() => _selectedImageFile = file);
  }

  Future<String?> _uploadImage() async {
    if (_selectedImageFile == null) return _imageUrlController.text.trim();
    setState(() => _uploadingImage = true);
    try {
      return await uploadOwnerPlaceImage(_selectedImageFile!, onError: _showError);
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      String? imageUrl = _imageUrlController.text.trim();
      if (_selectedImageFile != null) {
        imageUrl = await _uploadImage();
        if (imageUrl == null) { setState(() => _loading = false); return; }
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyToken) ?? '';

      // Stock
      int? stock;
      if (_hasReward && !_unlimitedStock) {
        stock = int.tryParse(_rewardStockController.text.trim());
      }

      final body = <String, dynamic>{
        'description': _descriptionController.text.trim(),
        'phone':       _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'address':     _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        'image_url':   imageUrl?.isEmpty == true ? null : imageUrl,
        // Datos de recompensa
        'has_reward':         _hasReward,
        'reward_icon':        _hasReward ? _selectedRewardIcon : null,
        'reward_name':        _hasReward ? _rewardNameController.text.trim() : null,
        'reward_description': _hasReward ? _rewardDescriptionController.text.trim() : null,
        'reward_stock':       _hasReward ? (_unlimitedStock ? null : stock) : null,
      };

      final response = await http.patch(
        Uri.parse('${AppConstants.backendUrl}/places/my-place'),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('✅ Información actualizada correctamente'),
            backgroundColor: Colors.green));
        widget.onSaved();
        Navigator.pop(context, true);
      } else {
        _showError(data['error']?.toString() ?? 'Error al guardar');
      }
    } catch (e) {
      if (mounted) _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red,
          duration: const Duration(seconds: 4)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: const BackButton(color: Colors.white),
            title: const Text('Editar mi Lugar'),
            backgroundColor: kPlaceEditTeal,
            foregroundColor: Colors.white,
            actions: [
              if (!_loading && !_uploadingImage)
                TextButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded, color: Colors.white, size: 18),
                  label: const Text('Guardar',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
              const SizedBox(width: 8),
            ]),
        body: (_loading || _uploadingImage)
            ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: kPlaceEditTeal),
              const SizedBox(height: 16),
              Text(_uploadingImage ? 'Subiendo imagen...' : 'Guardando...',
                  style: const TextStyle(fontSize: 16)),
            ]))
            : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Form(key: _formKey, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      placeEditSectionCard('📍 Información del Lugar',
                          buildPlaceEditInfoSection(widget.place)),
                      const SizedBox(height: 16),
                      placeEditSectionCard('📝 Descripción',
                          buildPlaceEditDescriptionSection(
                              descriptionController: _descriptionController)),
                      const SizedBox(height: 16),
                      placeEditSectionCard('📞 Contacto y Dirección',
                          buildPlaceEditContactSection(
                              phoneController: _phoneController,
                              addressController: _addressController)),
                      const SizedBox(height: 16),
                      placeEditSectionCard('🖼️ Imagen del Lugar',
                          buildPlaceEditImageSection(
                              currentImageUrl: widget.place.imageUrl,
                              selectedImageFile: _selectedImageFile,
                              imageUrlController: _imageUrlController,
                              uploadingImage: _uploadingImage,
                              onPickImage: _pickImage,
                              onClearImage: () => setState(() => _selectedImageFile = null))),
                      const SizedBox(height: 16),
                      placeEditSectionCard('🎁 Recompensa',
                          buildPlaceEditRewardSection(
                              hasReward: _hasReward,
                              onHasRewardChanged: (v) => setState(() => _hasReward = v),
                              selectedRewardIcon: _selectedRewardIcon,
                              rewardIcons: _rewardIcons,
                              onIconChanged: (icon) => setState(() => _selectedRewardIcon = icon),
                              rewardNameController: _rewardNameController,
                              rewardDescriptionController: _rewardDescriptionController,
                              rewardStockController: _rewardStockController,
                              unlimitedStock: _unlimitedStock,
                              onUnlimitedStockChanged: (v) => setState(() {
                                _unlimitedStock = v;
                                if (v) _rewardStockController.clear();
                              }))),
                      const SizedBox(height: 28),
                      SizedBox(
                          width: double.infinity, height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _loading || _uploadingImage ? null : _save,
                            icon: const Icon(Icons.save_rounded),
                            label: const Text('Guardar Cambios',
                                style: TextStyle(fontSize: 15)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kPlaceEditTeal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                          )),
                      const SizedBox(height: 24),
                    ])))))
    );
  }
}
