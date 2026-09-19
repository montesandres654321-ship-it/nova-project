// lib/models/place_model.dart
// ============================================================
// MODELO DE LUGAR — Nova App Móvil
// ============================================================
// Compatible con backend v6.0
// Incluye campos de recompensa para mostrar en detalle
// ============================================================

import 'dart:convert';

class Place {
  final int id;
  final String name;
  final String tipo;
  final String lugar;
  final String? municipio;
  final String description;
  final String? imageUrl;
  final double rating;
  final String? address;
  final String? phone;
  final String? priceRange;
  final List<String> amenities;
  final bool isActive;
  final double? latitud;
  final double? longitud;

  // Campos de recompensa (nuevos)
  final bool hasReward;
  final String? rewardName;
  final String? rewardIcon;
  final String? rewardDescription;
  final int? rewardStock;

  // Columnas preparadas para funcionalidad futura (BD_SCHEMA.md) — hoy
  // están vacías en producción para casi todos los lugares. Nulas/vacías
  // hasta que el dashboard las pueble; el detalle de lugar solo muestra
  // sus secciones cuando hay contenido real.
  final String? categoria;
  final String? historia;
  final List<String> disciplinas;

  Place({
    required this.id,
    required this.name,
    required this.tipo,
    required this.lugar,
    this.municipio,
    required this.description,
    this.imageUrl,
    this.rating = 0.0,
    this.address,
    this.phone,
    this.priceRange,
    required this.amenities,
    this.isActive = true,
    this.latitud,
    this.longitud,
    this.hasReward = false,
    this.rewardName,
    this.rewardIcon,
    this.rewardDescription,
    this.rewardStock,
    this.categoria,
    this.historia,
    this.disciplinas = const [],
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    // Parsear amenities robustamente
    List<String> amenitiesList = [];
    if (json['amenities'] != null) {
      if (json['amenities'] is String) {
        try {
          final parsed = jsonDecode(json['amenities']);
          if (parsed is List) amenitiesList = List<String>.from(parsed);
        } catch (_) {
          amenitiesList = (json['amenities'] as String)
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } else if (json['amenities'] is List) {
        amenitiesList = List<String>.from(json['amenities']);
      }
    }

    // disciplinas: mismo formato flexible que amenities (JSON array o
    // texto separado por comas) — la columna es TEXT en la BD.
    List<String> disciplinasList = [];
    if (json['disciplinas'] != null) {
      if (json['disciplinas'] is String) {
        try {
          final parsed = jsonDecode(json['disciplinas']);
          if (parsed is List) disciplinasList = List<String>.from(parsed);
        } catch (_) {
          disciplinasList = (json['disciplinas'] as String)
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } else if (json['disciplinas'] is List) {
        disciplinasList = List<String>.from(json['disciplinas']);
      }
    }

    return Place(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Sin nombre',
      tipo: json['tipo'] ?? 'hotel',
      lugar: json['lugar'] ?? 'Ubicación desconocida',
      municipio: json['municipio'],
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      rating: (json['rating'] ?? 0).toDouble(),
      address: json['address'],
      phone: json['phone'],
      priceRange: json['price_range'] ?? json['priceRange'],
      amenities: amenitiesList,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      // Campos de recompensa
      hasReward: json['has_reward'] == true || json['has_reward'] == 1,
      rewardName: json['reward_name'],
      rewardIcon: json['reward_icon'],
      rewardDescription: json['reward_description'],
      rewardStock: json['reward_stock'],
      categoria: (json['categoria'] as String?)?.trim().isNotEmpty == true ? json['categoria'] : null,
      historia: (json['historia'] as String?)?.trim().isNotEmpty == true ? json['historia'] : null,
      disciplinas: disciplinasList,
    );
  }

  // Etiquetas de los 13 tipos válidos (CHECK constraint de places.tipo,
  // ver BD_SCHEMA.md) — mismo mapeo que nova_dashboard/lib/models/place.dart
  // Sprint 3 Parte D, para que el badge de tipo no muestre "Lugar" genérico.
  static const Map<String, String> tiposLabels = {
    'hotel':               'Hotel',
    'restaurant':          'Restaurante',
    'bar':                 'Bar',
    'escenario_deportivo': 'Escenario deportivo',
    'parque':              'Parque',
    'naturaleza':          'Naturaleza',
    'cultura':             'Cultura',
    'artesania':           'Artesanía',
    'playa':               'Playa',
    'ruta':                'Ruta turística',
    'gastronomia':         'Gastronomía',
    'compras':             'Compras',
    'servicio':            'Servicio',
  };

  static const Map<String, String> tiposEmoji = {
    'hotel':               '🏨',
    'restaurant':          '🍽️',
    'bar':                 '🍹',
    'escenario_deportivo': '🏟️',
    'parque':              '🌳',
    'naturaleza':          '🌿',
    'cultura':             '🎭',
    'artesania':           '🧺',
    'playa':               '🏖️',
    'ruta':                '🗺️',
    'gastronomia':         '🍴',
    'compras':             '🛍️',
    'servicio':            '🛎️',
  };

  // Helpers de conveniencia
  String get tipoEmoji => tiposEmoji[tipo.toLowerCase()] ?? '📍';

  String get tipoLabel => tiposLabels[tipo.toLowerCase()] ?? 'Lugar';

  String get displayName => '$tipoEmoji $name';

  @override
  String toString() => 'Place{id: $id, name: $name, tipo: $tipo, lugar: $lugar}';
}