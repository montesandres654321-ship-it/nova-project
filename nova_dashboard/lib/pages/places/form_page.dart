// lib/pages/places/form_page.dart
// REFACTOR: las secciones del formulario y los helpers visuales se
// extrajeron a lib/pages/places/form/ (place_form_sections.dart,
// place_form_fields.dart, place_form_tokens.dart) para bajar de 726 a
// <300 líneas, sin cambiar comportamiento.
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/place.dart';
import '../../models/admin_model.dart';
import '../../services/place_service.dart';
import '../../services/admin_service.dart';
import 'form/place_form_image_upload.dart';
import 'form/place_form_layout.dart';
import 'form/place_form_sections.dart';
import 'form/place_form_tokens.dart';

class PlaceFormPage extends StatefulWidget {
  final Place? place;
  const PlaceFormPage({super.key, this.place});
  @override
  State<PlaceFormPage> createState() => _PlaceFormPageState();
}

class _PlaceFormPageState extends State<PlaceFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _loading        = false;
  bool _uploadingImage = false;

  late TextEditingController _nameController;
  late TextEditingController _lugarController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _amenitiesController;
  late TextEditingController _rewardNameController;
  late TextEditingController _rewardDescriptionController;
  late TextEditingController _rewardStockController;

  List<AdminModel> _availableOwners = [];
  int?    _selectedOwnerId;
  bool    _loadingOwners = false;
  PlatformFile? _selectedImageFile;

  String _selectedType       = 'hotel';
  bool   _isActive           = true;
  bool   _hasReward          = true;
  String _selectedRewardIcon = '☕';

  final List<String> _types = Place.tiposValidos;

  final List<Map<String, String>> _rewardIcons = [
    {'icon': '☕', 'label': 'Café'},
    {'icon': '🥤', 'label': 'Bebida'},
    {'icon': '🍔', 'label': 'Comida'},
    {'icon': '🍕', 'label': 'Pizza'},
    {'icon': '🍰', 'label': 'Postre'},
    {'icon': '🎁', 'label': 'Regalo'},
    {'icon': '💰', 'label': 'Descuento'},
    {'icon': '🎫', 'label': 'Cupón'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailableOwners();
    final p = widget.place;
    _nameController        = TextEditingController(text: p?.name ?? '');
    _lugarController       = TextEditingController(text: p?.lugar ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _imageUrlController    = TextEditingController(text: p?.imageUrl ?? '');
    _addressController     = TextEditingController(text: p?.address ?? '');
    _phoneController       = TextEditingController(text: p?.phone ?? '');
    _amenitiesController   = TextEditingController(
        text: p?.amenities.join(', ') ?? '');
    _rewardNameController        = TextEditingController(text: p?.rewardName ?? '');
    _rewardDescriptionController = TextEditingController(
        text: p?.rewardDescription ?? '');
    _rewardStockController = TextEditingController(
        text: p?.rewardStock?.toString() ?? '');
    if (p != null) {
      _selectedType       = p.tipo;
      _isActive           = p.isActive;
      _hasReward          = p.hasReward;
      _selectedRewardIcon = p.rewardIcon ?? '☕';
      _selectedOwnerId    = p.ownerAdminId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();        _lugarController.dispose();
    _descriptionController.dispose(); _imageUrlController.dispose();
    _addressController.dispose();     _phoneController.dispose();
    _amenitiesController.dispose();
    _rewardNameController.dispose();  _rewardDescriptionController.dispose();
    _rewardStockController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableOwners() async {
    setState(() => _loadingOwners = true);
    try {
      final owners = await AdminService.getOwnersWithoutPlace();
      setState(() { _availableOwners = owners; _loadingOwners = false; });
    } catch (_) {
      setState(() => _loadingOwners = false);
    }
  }

  Future<void> _pickImage() async {
    final file = await pickPlaceImage();
    if (file != null) setState(() => _selectedImageFile = file);
  }

  Future<String?> _uploadImage() async {
    if (_selectedImageFile == null) return null;
    setState(() => _uploadingImage = true);
    try {
      return await uploadPlaceImage(_selectedImageFile!, onError: _showError);
    } finally {
      setState(() => _uploadingImage = false);
    }
  }

  int? _parseStock(String raw) {
    final v = int.tryParse(raw);
    return (v == null || v == 0) ? null : v;
  }

  Future<void> _savePlace() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      String? imageUrl = _imageUrlController.text.trim();
      if (_selectedImageFile != null) {
        imageUrl = await _uploadImage();
        if (imageUrl == null) { setState(() => _loading = false); return; }
      }
      final amenities = _amenitiesController.text
          .split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final place = Place(
        id:          widget.place?.id ?? 0,
        name:        _nameController.text.trim(),
        tipo:        _selectedType,
        lugar:       _lugarController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl:    (imageUrl == null || imageUrl.isEmpty) ? null : imageUrl,
        rating:      0.0,
        address:     _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        phone:       _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        priceRange:  null,
        amenities:   amenities,
        isActive:    _isActive,
        hasReward:   _hasReward,
        rewardName:  _hasReward ? _rewardNameController.text.trim() : null,
        rewardDescription: _hasReward ? _rewardDescriptionController.text.trim() : null,
        rewardIcon:  _hasReward ? _selectedRewardIcon : null,
        rewardStock: _hasReward ? _parseStock(_rewardStockController.text.trim()) : null,
        ownerAdminId: _selectedOwnerId,
      );

      final result = widget.place == null
          ? await PlaceService.createPlace(place)
          : await PlaceService.updatePlace(widget.place!.id, place);

      if (!mounted) return;
      if (result['success'] == true) {
        _showSuccess(result['message']?.toString() ??
            (widget.place == null ? 'Lugar creado' : 'Lugar actualizado'));
        Navigator.pop(context, true);
      } else {
        _showError(result['error']?.toString() ?? 'Error al guardar');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deletePlace() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar lugar'),
        content: Text('¿Eliminar "${widget.place!.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _loading = true);
    final result = await PlaceService.deletePlace(widget.place!.id);
    if (!mounted) return;
    if (result['success'] == true) {
      _showSuccess('Lugar eliminado');
      Navigator.pop(context, true);
    } else {
      _showError(result['error']?.toString() ?? 'Error al eliminar');
      setState(() => _loading = false);
    }
  }

  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green,
          duration: const Duration(seconds: 3)));

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red,
          duration: const Duration(seconds: 4)));

  // ── BUILD ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPlaceFormBg,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: Text(widget.place == null ? 'Nuevo Lugar' : 'Editar Lugar'),
        backgroundColor: kPlaceFormTeal,
        foregroundColor: Colors.white,
        actions: [
          if (widget.place != null)
            IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _loading ? null : _deletePlace,
                tooltip: 'Eliminar'),
        ],
      ),
      body: (_loading || _uploadingImage)
          ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: kPlaceFormTeal),
                const SizedBox(height: 16),
                Text(_uploadingImage ? 'Subiendo imagen...' : 'Guardando...',
                    style: const TextStyle(fontSize: 16)),
              ]))
          : placeFormBody(
              infoBasica: _infoBasicaSection(),
              imagen: _imagenSection(),
              detalles: _detallesSection(),
              propietario: _propietarioSection(),
              recompensa: _recompensaSection(),
              loading: _loading,
              uploadingImage: _uploadingImage,
              isEditing: widget.place != null,
              onSave: _savePlace,
              formKey: _formKey,
            ),
    );
  }

  // ── Contenido por sección (delegado a form/place_form_sections.dart) ──

  List<Widget> _infoBasicaSection() => buildInfoBasicaSection(
      nameController: _nameController,
      lugarController: _lugarController,
      descriptionController: _descriptionController,
      selectedType: _selectedType,
      types: _types,
      onTypeChanged: (v) => setState(() => _selectedType = v!));

  List<Widget> _imagenSection() => buildImagenSection(
      imageUrlController: _imageUrlController,
      selectedImageFile: _selectedImageFile,
      uploadingImage: _uploadingImage,
      onPickImage: _pickImage,
      onClearImage: () => setState(() => _selectedImageFile = null));

  List<Widget> _detallesSection() => buildDetallesSection(
      addressController: _addressController,
      phoneController: _phoneController,
      amenitiesController: _amenitiesController,
      isActive: _isActive,
      onActiveChanged: (v) => setState(() => _isActive = v));

  List<Widget> _recompensaSection() => buildRecompensaSection(
      hasReward: _hasReward,
      onHasRewardChanged: (v) => setState(() => _hasReward = v),
      selectedRewardIcon: _selectedRewardIcon,
      rewardIcons: _rewardIcons,
      onIconChanged: (icon) => setState(() => _selectedRewardIcon = icon),
      rewardNameController: _rewardNameController,
      rewardDescriptionController: _rewardDescriptionController,
      rewardStockController: _rewardStockController);

  List<Widget> _propietarioSection() => buildPropietarioSection(
      loadingOwners: _loadingOwners,
      selectedOwnerId: _selectedOwnerId,
      availableOwners: _availableOwners,
      onOwnerChanged: (v) => setState(() => _selectedOwnerId = v));
}
