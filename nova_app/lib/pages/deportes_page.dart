// lib/pages/deportes_page.dart
// ============================================================
// PANTALLA DEPORTES — Juegos Nacionales 2027 · Nova App Móvil
// ============================================================
// Datos tenttativos / hardcoded — entorno de pruebas.
// Cuando exista el endpoint oficial, reemplazar _kDisciplinas
// y _kCalendario con una llamada al backend.
// ============================================================

import 'package:flutter/material.dart';
import '../core/design/app_colors.dart';

// ── Modelos internos ─────────────────────────────────────────
class _Disciplina {
  final IconData icono;
  final String nombre;
  final String sede;
  final String fecha;
  const _Disciplina({
    required this.icono,
    required this.nombre,
    required this.sede,
    required this.fecha,
  });
}

class _EventoCalendario {
  final String fecha;
  final String disciplina;
  final String descripcion;
  final String sede;
  const _EventoCalendario({
    required this.fecha,
    required this.disciplina,
    required this.descripcion,
    required this.sede,
  });
}

// ── Datos tenttativos ─────────────────────────────────────────
const _kDisciplinas = [
  _Disciplina(
    icono: Icons.pool_rounded,
    nombre: 'Natación',
    sede: 'Sincelejo',
    fecha: '14–18 Oct 2027',
  ),
  _Disciplina(
    icono: Icons.sports_soccer_rounded,
    nombre: 'Fútbol',
    sede: 'Coveñas',
    fecha: '10–20 Oct 2027',
  ),
  _Disciplina(
    icono: Icons.sports_basketball_rounded,
    nombre: 'Baloncesto',
    sede: 'Santiago de Tolú',
    fecha: '12–19 Oct 2027',
  ),
  _Disciplina(
    icono: Icons.sports_volleyball_rounded,
    nombre: 'Voleibol',
    sede: 'Sincelejo',
    fecha: '11–17 Oct 2027',
  ),
  _Disciplina(
    icono: Icons.directions_bike_rounded,
    nombre: 'Ciclismo',
    sede: 'Coveñas',
    fecha: '15–16 Oct 2027',
  ),
  _Disciplina(
    icono: Icons.sports_martial_arts_rounded,
    nombre: 'Judo',
    sede: 'Sincelejo',
    fecha: '13–14 Oct 2027',
  ),
  _Disciplina(
    icono: Icons.sports_tennis_rounded,
    nombre: 'Tenis de mesa',
    sede: 'Santiago de Tolú',
    fecha: '10–13 Oct 2027',
  ),
  _Disciplina(
    icono: Icons.rowing_rounded,
    nombre: 'Remo',
    sede: 'Coveñas',
    fecha: '17–18 Oct 2027',
  ),
];

const _kCalendario = [
  _EventoCalendario(
    fecha: '10 Oct',
    disciplina: 'Apertura',
    descripcion: 'Ceremonia de inauguración Juegos Nacionales 2027',
    sede: 'Sincelejo',
  ),
  _EventoCalendario(
    fecha: '12 Oct',
    disciplina: 'Natación',
    descripcion: 'Pruebas clasificatorias 100m libre y 200m mariposa',
    sede: 'Sincelejo',
  ),
  _EventoCalendario(
    fecha: '14 Oct',
    disciplina: 'Fútbol',
    descripcion: 'Cuartos de final rama masculina',
    sede: 'Coveñas',
  ),
  _EventoCalendario(
    fecha: '15 Oct',
    disciplina: 'Ciclismo',
    descripcion: 'Ruta individual contra el reloj — Costa Morrosquillo',
    sede: 'Coveñas',
  ),
  _EventoCalendario(
    fecha: '17 Oct',
    disciplina: 'Baloncesto',
    descripcion: 'Semifinales rama femenina y masculina',
    sede: 'Santiago de Tolú',
  ),
  _EventoCalendario(
    fecha: '19 Oct',
    disciplina: 'Natación',
    descripcion: 'Finales y entrega de medallas',
    sede: 'Sincelejo',
  ),
  _EventoCalendario(
    fecha: '21 Oct',
    disciplina: 'Clausura',
    descripcion: 'Ceremonia de clausura y desfile de deportistas',
    sede: 'Sincelejo',
  ),
];

// ── Widget principal ──────────────────────────────────────────
class DeportesPage extends StatelessWidget {
  const DeportesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(context),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Disciplinas', AppColors.bienvenidaVerde),
                    const SizedBox(height: 14),
                    _buildDisciplinas(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Calendario destacado', AppColors.bienvenidaAzul),
                    const SizedBox(height: 14),
                    _buildCalendario(),
                    const SizedBox(height: 24),
                    _buildBanner(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero ─────────────────────────────────────────────────────
  static const _kCoral1 = AppColors.bienvenidaCoral;
  static const _kCoral2 = AppColors.categoriaGastro;

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
              'assets/images/home/foto-deportes.png',
              fit: BoxFit.cover,
            ),
            // Gradiente de color encima
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _kCoral1.withValues(alpha: 0.30),
                    _kCoral2.withValues(alpha: 0.88),
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
                  // Botón atrás
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
                  // Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
                    ),
                    child: Text(
                      'Juegos Nacionales y Paranacionales',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Deportes 2027',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Golfo de Morrosquillo, Sucre · Octubre 2027',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Stats rápidos — Row para que los 3 queden siempre en línea
                  Row(
                    children: [
                      Expanded(child: _buildStatChip(Icons.emoji_events_rounded, '${_kDisciplinas.length}', 'Disciplinas')),
                      const SizedBox(width: 6),
                      Expanded(child: _buildStatChip(Icons.calendar_today_rounded, '${_kCalendario.length}', 'Eventos')),
                      const SizedBox(width: 6),
                      Expanded(child: _buildStatChip(Icons.location_on_rounded, '3', 'Sedes')),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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

  // ── Título de sección ─────────────────────────────────────────
  Widget _buildSectionTitle(String titulo, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        titulo,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  // ── Grid disciplinas ──────────────────────────────────────────
  Widget _buildDisciplinas() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _kDisciplinas.length,
        itemBuilder: (_, i) => _buildCardDisciplina(_kDisciplinas[i]),
      ),
    );
  }

  Widget _buildCardDisciplina(_Disciplina d) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.bienvenidaBorde),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.categoriaGastroBg,
              shape: BoxShape.circle,
            ),
            child: Icon(d.icono, size: 18, color: AppColors.bienvenidaCoral),
          ),
          const SizedBox(height: 6),
          Text(
            d.nombre,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.bienvenidaTextoFuerte,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 10, color: AppColors.textHint),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  d.sede,
                  style: TextStyle(fontSize: 10, color: AppColors.textHint),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            d.fecha,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.bienvenidaCoral,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Calendario ────────────────────────────────────────────────
  Widget _buildCalendario() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (var i = 0; i < _kCalendario.length; i++) ...[
            _buildEventoCalendario(_kCalendario[i], i == 0),
            if (i != _kCalendario.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildEventoCalendario(_EventoCalendario e, bool esPrimero) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: esPrimero ? AppColors.categoriaGastroBg : Colors.white,
        border: Border.all(
          color: esPrimero
              ? AppColors.bienvenidaCoral.withValues(alpha: 0.3)
              : AppColors.bienvenidaBorde,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fecha
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: esPrimero ? AppColors.bienvenidaCoral : const Color(0xFFF0F4F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              e.fecha,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: esPrimero ? Colors.white : AppColors.bienvenidaAzul,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.disciplina,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.bienvenidaTextoFuerte,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  e.descripcion,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 16 / 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 10, color: AppColors.textHint),
                    const SizedBox(width: 3),
                    Text(
                      e.sede,
                      style: TextStyle(fontSize: 10, color: AppColors.textHint),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Banner informativo ────────────────────────────────────────
  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F8F0),
          border: Border.all(color: AppColors.bienvenidaVerde.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.bienvenidaVerde,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline_rounded, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información tentativa',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bienvenidaVerde,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Los datos de disciplinas y fechas son aproximados. La programación oficial se publicará próximamente.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 15 / 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
