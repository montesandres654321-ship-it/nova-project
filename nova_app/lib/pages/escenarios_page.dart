// lib/pages/escenarios_page.dart
// ============================================================
// PANTALLA ESCENARIOS — Juegos Nacionales 2027 · Nova App Móvil
// ============================================================
// Datos tenttativos / hardcoded — entorno de pruebas.
// Cuando exista el endpoint oficial, reemplazar _kEscenarios
// con una llamada al backend.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';

// ── Modelos internos ─────────────────────────────────────────
class _Escenario {
  final String nombre;
  final String municipio;
  final String direccion;
  final List<String> disciplinas;
  final int capacidad;
  final String estado;
  final IconData icono;
  final Color colorFondo;
  const _Escenario({
    required this.nombre,
    required this.municipio,
    required this.direccion,
    required this.disciplinas,
    required this.capacidad,
    required this.estado,
    required this.icono,
    required this.colorFondo,
  });
}

// ── Datos tenttativos ─────────────────────────────────────────
const _kEscenarios = [
  _Escenario(
    nombre: 'Coliseo Nicanor Insignares',
    municipio: 'Sincelejo',
    direccion: 'Carrera 14 con Calle 30, Sincelejo',
    disciplinas: ['Baloncesto', 'Voleibol', 'Balonmano'],
    capacidad: 5000,
    estado: 'Habilitado',
    icono: Icons.stadium_rounded,
    colorFondo: AppColors.sistemaAzulClaro,
  ),
  _Escenario(
    nombre: 'Estadio Jaraguay',
    municipio: 'Sincelejo',
    direccion: 'Av. Las Peñitas, Sincelejo',
    disciplinas: ['Atletismo', 'Fútbol'],
    capacidad: 12000,
    estado: 'Habilitado',
    icono: Icons.sports_soccer_rounded,
    colorFondo: AppColors.sistemaVerdeClaro,
  ),
  _Escenario(
    nombre: 'Unidad Acuática Municipal',
    municipio: 'Sincelejo',
    direccion: 'Barrio Olímpico, Sincelejo',
    disciplinas: ['Natación', 'Waterpolo'],
    capacidad: 2000,
    estado: 'En adecuación',
    icono: Icons.pool_rounded,
    colorFondo: AppColors.sistemaAzulClaro,
  ),
  _Escenario(
    nombre: 'Escenario Deportivo Coveñas',
    municipio: 'Coveñas',
    direccion: 'Malecón de Coveñas, frente a Punta Bolívar',
    disciplinas: ['Ciclismo', 'Triatlón', 'Fútbol playa'],
    capacidad: 3000,
    estado: 'Habilitado',
    icono: Icons.directions_bike_rounded,
    colorFondo: AppColors.categoriaGastroBg,
  ),
  _Escenario(
    nombre: 'Polideportivo Santiago de Tolú',
    municipio: 'Santiago de Tolú',
    direccion: 'Centro deportivo, Santiago de Tolú',
    disciplinas: ['Tenis de mesa', 'Judo', 'Boxeo'],
    capacidad: 1500,
    estado: 'Habilitado',
    icono: Icons.sports_martial_arts_rounded,
    colorFondo: AppColors.categoriaPatrimonioBg,
  ),
  _Escenario(
    nombre: 'Cancha Múltiple Tolú',
    municipio: 'Santiago de Tolú',
    direccion: 'Calle principal, barrio Deportivo, Tolú',
    disciplinas: ['Baloncesto 3x3', 'Voleibol playa'],
    capacidad: 800,
    estado: 'En adecuación',
    icono: Icons.sports_basketball_rounded,
    colorFondo: Color(0xFFFFF8E7),
  ),
];

// ── Filtros de municipio ──────────────────────────────────────
const _kMunicipios = ['Todos', 'Sincelejo', 'Coveñas', 'Santiago de Tolú'];

// ── Widget principal ──────────────────────────────────────────
class EscenariosPage extends StatefulWidget {
  const EscenariosPage({super.key});

  @override
  State<EscenariosPage> createState() => _EscenariosPageState();
}

class _EscenariosPageState extends State<EscenariosPage> {
  String _filtroActual = 'Todos';

  List<_Escenario> get _escenariosFiltrados {
    if (_filtroActual == 'Todos') return _kEscenarios;
    return _kEscenarios.where((e) => e.municipio == _filtroActual).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHero(context),
            _buildFiltros(),
            Expanded(
              child: _escenariosFiltrados.isEmpty
                  ? _buildVacio()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      itemCount: _escenariosFiltrados.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildCardEscenario(_escenariosFiltrados[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero ─────────────────────────────────────────────────────
  Widget _buildHero(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 240,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Foto de portada
            Image.asset(
              'assets/images/rutas/foto-escenarios-deportivos.png',
              fit: BoxFit.cover,
            ),
            // Gradiente azul encima
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.bienvenidaAzul.withValues(alpha: 0.30),
                    const Color(0xFF0A3D6E).withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
                    ),
                    child: Text(
                      'Juegos Nacionales y Paranacionales',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Escenarios 2027',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sedes de competencia en el Golfo de Morrosquillo',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildStatChip(Icons.stadium_rounded, '${_kEscenarios.length}', 'Escenarios'),
                      _buildStatChip(Icons.location_city_rounded, '3', 'Municipios'),
                      _buildStatChip(
                        Icons.check_circle_rounded,
                        '${_kEscenarios.where((e) => e.estado == 'Habilitado').length}',
                        'Habilitados',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String valor, String etiqueta) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(valor, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
              Text(etiqueta, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.8))),
            ],
          ),
        ],
      ),
    );
  }

  // ── Filtros por municipio ─────────────────────────────────────
  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final m in _kMunicipios) ...[
              _buildChipFiltro(m),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChipFiltro(String municipio) {
    final activo = _filtroActual == municipio;
    return GestureDetector(
      onTap: () => setState(() => _filtroActual = municipio),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? AppColors.bienvenidaAzul : const Color(0xFFF0F4F8),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          municipio,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: activo ? Colors.white : AppColors.bienvenidaTextoFuerte,
          ),
        ),
      ),
    );
  }

  // ── Card escenario ────────────────────────────────────────────
  Widget _buildCardEscenario(_Escenario e) {
    final habilitado = e.estado == 'Habilitado';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.bienvenidaBorde),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: e.colorFondo,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(e.icono, size: 24, color: AppColors.bienvenidaAzul),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.nombre,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.bienvenidaTextoFuerte,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textHint),
                        const SizedBox(width: 3),
                        Text(
                          e.municipio,
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Badge estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: habilitado ? AppColors.sistemaVerdeClaro : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  e.estado,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: habilitado ? AppColors.bienvenidaVerde : const Color(0xFFB8860B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Dirección
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textHint),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  e.direccion,
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Disciplinas
          Wrap(
            spacing: 6,
            runSpacing: 5,
            children: [
              for (final d in e.disciplinas)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.sistemaAzulClaro,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bienvenidaAzul,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Capacidad
          Row(
            children: [
              const Icon(Icons.people_rounded, size: 12, color: AppColors.textHint),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${e.capacidad.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} espectadores',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Estado vacío ──────────────────────────────────────────────
  Widget _buildVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: AppColors.textHint.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            'No hay escenarios en este municipio',
            style: TextStyle(fontSize: 14, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
