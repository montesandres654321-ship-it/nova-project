// lib/pages/places/list_tab.dart
// ============================================================
// REDESIGN: SaaS-style cards · context menu · premium filters
// Lógica, servicios y navegación sin cambios
// REFACTOR: header, tarjeta y estado vacío extraídos a
// lib/pages/places/widgets/ para bajar de 700 a <300 líneas.
// ============================================================
import 'package:flutter/material.dart';
import '../../models/place.dart';
import '../../services/place_service.dart';
import 'form_page.dart';
import 'places_tokens.dart';
import 'qr_dialog.dart';
import '../place_details_page.dart';
import 'widgets/place_card.dart';
import 'widgets/places_empty_state.dart';
import 'widgets/places_header.dart';

class PlacesListTab extends StatefulWidget {
  final String? initialFilter;
  final bool    canEdit;
  final bool    canViewInfo;

  const PlacesListTab({
    super.key,
    this.initialFilter,
    this.canEdit     = true,
    this.canViewInfo = true,
  });

  @override
  State<PlacesListTab> createState() => _PlacesListTabState();
}

class _PlacesListTabState extends State<PlacesListTab> {

  // ── State — SIN CAMBIOS ───────────────────────────────────
  List<Place> _places         = [];
  List<Place> _filteredPlaces = [];
  bool   _loading       = true;
  late String _selectedFilter;
  String _searchQuery   = '';

  // Filtro de estado (UI-only, no toca servicios)
  String _statusFilter  = 'all'; // 'all' | 'active' | 'inactive'

  final List<Map<String, dynamic>> _filters = [
    {'value': 'all',        'label': '🗺️ Todos'},
    {'value': 'hotel',      'label': '🏨 Hoteles'},
    {'value': 'restaurant', 'label': '🍽️ Restaurantes'},
    {'value': 'bar',        'label': '🍹 Bares'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter ?? 'all';
    _loadPlaces();
  }

  // ── LÓGICA — SIN CAMBIOS ─────────────────────────────────
  Future<void> _loadPlaces() async {
    setState(() => _loading = true);
    try {
      final places = _selectedFilter == 'all'
          ? await PlaceService.getPlaces()
          : await PlaceService.getPlacesByType(_selectedFilter);
      setState(() { _places = places; _filterPlaces(); });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error cargando lugares: $e'),
            backgroundColor: Colors.red));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  void _filterPlaces() {
    var list = _places;
    if (_searchQuery.isNotEmpty) {
      list = list.where((p) =>
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.lugar.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_statusFilter == 'active')   { list = list.where((p) =>  p.isActive).toList(); }
    if (_statusFilter == 'inactive') { list = list.where((p) => !p.isActive).toList(); }
    setState(() => _filteredPlaces = list);
  }

  Future<void> _togglePlaceStatus(Place place) async {
    final activate = !place.isActive;
    final label = activate ? 'Activar' : 'Desactivar';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$label lugar'),
        content: Text('¿$label "${place.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: activate ? kPlacesGreen : kPlacesRed, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: Text(label),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final result = await PlaceService.togglePlaceStatus(place.id, activate: activate);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result['success'] == true ? result['message'] ?? 'Estado actualizado' : result['error'] ?? 'Error'),
      backgroundColor: result['success'] == true ? Colors.green : Colors.red,
    ));
    if (result['success'] == true) _loadPlaces();
  }

  void _showDeleteDialog(Place place) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Confirmar eliminación'),
      content: Text('¿Eliminar "${place.name}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(
            onPressed: () { Navigator.pop(context); _deletePlace(place.id); },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar')),
      ],
    ));
  }

  Future<void> _deletePlace(int id) async {
    final result = await PlaceService.deletePlace(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['success'] == true
            ? 'Lugar desactivado' : result['error'] ?? 'Error'),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red));
    if (result['success'] == true) _loadPlaces();
  }

  void _showQRDialog(Place place) {
    showDialog(context: context, builder: (_) => QRDialog(place: place));
  }

  void _addPlace() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaceFormPage()))
        .then((_) => _loadPlaces());
  }

  void _handleAction(String action, Place place) {
    switch (action) {
      case 'view':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => PlaceDetailsPage(place: place)));
        break;
      case 'qr':
        _showQRDialog(place);
        break;
      case 'edit':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => PlaceFormPage(place: place)))
            .then((_) => _loadPlaces());
        break;
      case 'toggle':
        _togglePlaceStatus(place);
        break;
      case 'delete':
        _showDeleteDialog(place);
        break;
    }
  }

  // ─────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isFiltered = _searchQuery.isNotEmpty || _statusFilter != 'all';
    return ColoredBox(
      color: kPlacesBgPage,
      child: Column(children: [

        PlacesHeader(
          canEdit: widget.canEdit,
          filters: _filters,
          selectedFilter: _selectedFilter,
          statusFilter: _statusFilter,
          resultCount: _filteredPlaces.length,
          onAddPlace: _addPlace,
          onSearchChanged: (v) { setState(() => _searchQuery = v); _filterPlaces(); },
          onFilterSelected: (v) { setState(() => _selectedFilter = v); _loadPlaces(); },
          onStatusFilterToggled: (v) {
            setState(() => _statusFilter = _statusFilter == v ? 'all' : v);
            _filterPlaces();
          },
        ),
        const Divider(height: 1, thickness: 0.5, color: kPlacesBorder),

        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: kPlacesPrimary))
              : _filteredPlaces.isEmpty
                  ? PlacesEmptyState(
                      isFiltered: isFiltered,
                      canEdit: widget.canEdit,
                      onAddPlace: _addPlace,
                    )
                  : LayoutBuilder(builder: (_, box) {
                      final isDesktop = box.maxWidth > 700;
                      if (isDesktop) {
                        return RefreshIndicator(
                          onRefresh: _loadPlaces,
                          color: kPlacesPrimary,
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 0,
                              mainAxisExtent: 140,
                            ),
                            itemCount: _filteredPlaces.length,
                            itemBuilder: (_, i) => PlaceCard(
                                place: _filteredPlaces[i],
                                canEdit: widget.canEdit,
                                canViewInfo: widget.canViewInfo,
                                onAction: _handleAction),
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: _loadPlaces,
                        color: kPlacesPrimary,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                          itemCount: _filteredPlaces.length,
                          itemBuilder: (_, i) => PlaceCard(
                              place: _filteredPlaces[i],
                              canEdit: widget.canEdit,
                              canViewInfo: widget.canViewInfo,
                              onAction: _handleAction),
                        ),
                      );
                    }),
        ),
      ]),
    );
  }
}
