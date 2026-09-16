# REFACTORIZACIÓN COMPLETA NOVA APP
## Plan maestro — Máximo 300 líneas por archivo

**Objetivo:** Pasar de arquitectura monolítica a feature-first  
**Duración estimada:** 5-7 horas  
**Commits:** ~15-20 pequeños, uno por cada cambio  
**Rama:** feat/nuevas-interfaces-app-movil

---

## FASE 0 — Preparación (5 min)

```bash
cd C:\Users\usuario\Documents\proyecto\nova_app

# Verificar estado limpio
git status
# Debe mostrar: working tree clean

# Crear rama temporal de backup (opcional)
git branch backup/before-refactor

# Actualizar dependencias
flutter pub get

# Verificar estado inicial
flutter analyze lib/
# Debe dar: No issues found!
```

---

## FASE 1 — Servicios (api_service.dart: 533 líneas → 5 servicios)

**Tiempo:** 60-90 minutos  
**Riesgo:** Bajo  
**Complejidad:** Media

### PASO 1.1 — Crear auth_service.dart

```
NUEVO ARCHIVO: lib/services/auth_service.dart

Métodos a extraer desde api_service.dart:
- login(email, password) → POST /auth/login
- register(userData) → POST /auth/register  
- forgotPassword(email) → POST /auth/forgot-password
- changePassword(currentPassword, newPassword) → PUT /auth/change-password
- googleSignIn(googleToken) → POST /auth/google
- logout() → limpiar token

Dependencias:
- Usar AppConstants.apiUrl desde lib/utils/constants.dart
- SharedPreferences para guardar token
- Mantener método privado _makeRequest() para requests genéricas

VERIFICAR:
- flutter analyze lib/services/auth_service.dart
- Que no haya imports de otros servicios
- Que todos los métodos sean públicos
- Que maneje errores correctamente

COMMIT:
git add lib/services/auth_service.dart
git commit -m "feat: crear auth_service.dart — extraer métodos de autenticación"
```

### PASO 1.2 — Crear places_service.dart

```
NUEVO ARCHIVO: lib/services/places_service.dart

Métodos a extraer:
- getPlaces() → GET /places
- getPlacesByType(type) → GET /places?tipo=X
- getPlaceDetail(placeId) → GET /places/:id
- searchPlaces(query) → GET /places?search=X

Dependencias:
- place_model.dart para tipado
- AppConstants

VERIFICAR:
- flutter analyze lib/services/places_service.dart
- Imports de modelos correctos
- Manejo de errores

COMMIT:
git add lib/services/places_service.dart
git commit -m "feat: crear places_service.dart — extraer métodos de lugares"
```

### PASO 1.3 — Crear scan_service.dart

```
NUEVO ARCHIVO: lib/services/scan_service.dart

Métodos a extraer:
- scanQR(qrCode, placeId) → POST /scans
- getScanHistory(userId) → GET /scans/history/:userId
- getRecentScans(limit) → GET /scans/recent?limit=X
- completeScan(scanId, data) → PUT /scans/:id

Dependencias:
- scan_record.dart para tipado

VERIFICAR:
- flutter analyze lib/services/scan_service.dart

COMMIT:
git add lib/services/scan_service.dart
git commit -m "feat: crear scan_service.dart — extraer métodos de escaneo QR"
```

### PASO 1.4 — Crear rewards_service.dart

```
NUEVO ARCHIVO: lib/services/rewards_service.dart

Métodos a extraer:
- getUserRewards(userId) → GET /rewards/user/:userId
- redeemReward(rewardId) → POST /rewards/:id/redeem
- getAvailableRewards() → GET /rewards/available

VERIFICAR:
- flutter analyze lib/services/rewards_service.dart

COMMIT:
git add lib/services/rewards_service.dart
git commit -m "feat: crear rewards_service.dart — extraer métodos de recompensas"
```

### PASO 1.5 — Crear profile_service.dart

```
NUEVO ARCHIVO: lib/services/profile_service.dart

Métodos a extraer:
- getProfile(userId) → GET /users/:userId
- updateProfile(userId, data) → PUT /users/:userId
- updatePassword(userId, data) → PUT /users/:userId/password
- deleteAccount(userId) → DELETE /users/:userId

VERIFICAR:
- flutter analyze lib/services/profile_service.dart

COMMIT:
git add lib/services/profile_service.dart
git commit -m "feat: crear profile_service.dart — extraer métodos de perfil"
```

### PASO 1.6 — Actualizar api_service.dart

```
MODIFICAR: lib/services/api_service.dart (533 → 150 líneas)

QUÉ HACER:
1. Mantener solo métodos de compatibilidad hacia atrás
   - Las páginas aún importan api_service
2. Los métodos públicos deben llamar a los nuevos servicios:

   login(email, password) async {
     return AuthService().login(email, password);
   }

   getPlaces() async {
     return PlacesService().getPlaces();
   }

3. Agregar clase ApiClient base si no existe
4. Centralizar manejo de errores

VERIFICAR:
- flutter analyze lib/services/api_service.dart
- Que siga funcionando para páginas que lo usan

COMMIT:
git add lib/services/api_service.dart
git commit -m "refactor: api_service.dart — delegación a servicios especializados"
```

### PASO 1.7 — Verificación de FASE 1

```bash
cd C:\Users\usuario\Documents\proyecto\nova_app

# Análisis completo
flutter analyze lib/

# Debe dar: No issues found!
# Si hay errores, reportar cuáles

# Build debug
flutter build apk --debug

# Debe compilar sin errores

# Probar en dispositivo
flutter run -d DEVICE_ID

# Verificar que login sigue funcionando
# Verificar que explorar lugares sigue funcionando
```

**COMMIT FINAL DE FASE 1:**
```bash
git add -A
git commit -m "refactor: FASE 1 completa — servicios monolíticos divididos"
git push origin feat/nuevas-interfaces-app-movil
```

---

## FASE 2 — Páginas Críticas (Autenticación)

### PASO 2.1 — login_page.dart (548 → 250 líneas)

```
ARCHIVO: lib/pages/login_page.dart (548 líneas)

PROBLEMA:
- Formulario completo
- Validaciones
- Manejo de errores
- Lógica de login
- UI todo mezclado

SOLUCIÓN:
1. Crear widget: lib/widgets/login_form.dart
   - buildForm() completo
   - Validación inline
   - TextFields

2. Crear widget: lib/widgets/password_input.dart
   - Campo de contraseña reutilizable

3. Mover validaciones a: lib/utils/validators.dart (si no existe)

4. login_page.dart solo:
   - Estructura Scaffold
   - BuildContext y navegación
   - Llamadas a AuthService

CHECKLIST:
- [ ] Crear lib/widgets/login_form.dart
- [ ] Crear lib/widgets/password_input.dart (reutilizable)
- [ ] Mover validaciones a lib/utils/validators.dart
- [ ] Actualizar lib/pages/login_page.dart (250 líneas)
- [ ] flutter analyze → 0 errores
- [ ] Testear login en dispositivo

COMMIT:
git add lib/pages/login_page.dart lib/widgets/login_form.dart lib/widgets/password_input.dart lib/utils/validators.dart
git commit -m "refactor: login_page — dividir en widgets + validaciones"
```

### PASO 2.2 — register_page.dart (580 → 250 líneas)

```
ARCHIVO: lib/pages/register_page.dart (580 líneas)

REUTILIZAR:
- lib/widgets/password_input.dart (crear en 2.1)
- lib/utils/validators.dart (crear en 2.1)

NUEVO:
- lib/widgets/register_form.dart
- lib/widgets/email_input.dart (reutilizable)
- lib/widgets/terms_checkbox.dart (reutilizable)

HACER:
- Similar a login_page pero con más campos
- Reutilizar componentes de login
- Reducir a 250 líneas

COMMIT:
git add lib/pages/register_page.dart lib/widgets/register_form.dart lib/widgets/email_input.dart lib/widgets/terms_checkbox.dart
git commit -m "refactor: register_page — dividir en widgets reutilizables"
```

### PASO 2.3 — forgot_password_page.dart (379 → 180 líneas)

```
ARCHIVO: lib/pages/forgot_password_page.dart (379 líneas)

REUTILIZAR:
- lib/widgets/email_input.dart

HACER:
- Simplificar UI
- Extraer form a widget si es necesario
- Máximo 180 líneas

COMMIT:
git add lib/pages/forgot_password_page.dart
git commit -m "refactor: forgot_password_page — simplificar UI"
```

### PASO 2.4 — change_password_page.dart (254 → 180 líneas)

```
ARCHIVO: lib/pages/change_password_page.dart (254 líneas)

REUTILIZAR:
- lib/widgets/password_input.dart
- lib/utils/validators.dart

HACER:
- Extraer form
- Máximo 180 líneas

COMMIT:
git add lib/pages/change_password_page.dart
git commit -m "refactor: change_password_page — usar password_input reutilizable"
```

**VERIFICACIÓN FASE 2:**
```bash
flutter analyze lib/
flutter run -d DEVICE_ID
# Testear: login, register, forgot password, change password

git commit -m "refactor: FASE 2 completa — autenticación optimizada"
```

---

## FASE 3 — Vistas Principales

### PASO 3.1 — history_page.dart (808 → 250 líneas) — LA MÁS GRANDE

```
ARCHIVO: lib/pages/history_page.dart (808 líneas) ← CRÍTICA

PROBLEMA:
- 2 tabs completamente diferentes
- Lista de escaneos
- Lista de recompensas
- Filtros duplicados
- Lógica entrelazada

SOLUCIÓN:
1. Crear lib/widgets/scan_history_list.dart (200 líneas)
   - Lista de escaneos
   - Card por escaneo
   - Filtros de escaneo

2. Crear lib/widgets/rewards_history_list.dart (150 líneas)
   - Lista de recompensas
   - Card por recompensa
   - Estado de recompensa (usado/pendiente)

3. Crear lib/widgets/history_empty_state.dart (50 líneas)
   - Estado vacío reutilizable

4. Actualizar history_page.dart (250 líneas)
   - TabBar: Escaneos | Recompensas
   - TabBarView: scan_history_list + rewards_history_list
   - Acciones de arriba (filtros, compartir)

CHECKLIST:
- [ ] Crear lib/widgets/scan_history_list.dart
- [ ] Crear lib/widgets/rewards_history_list.dart
- [ ] Crear lib/widgets/history_empty_state.dart
- [ ] Actualizar lib/pages/history_page.dart (reducir a 250)
- [ ] flutter analyze → 0 errores
- [ ] Testear ambos tabs en dispositivo

COMMIT:
git add lib/pages/history_page.dart lib/widgets/scan_history_list.dart lib/widgets/rewards_history_list.dart lib/widgets/history_empty_state.dart
git commit -m "refactor: history_page — dividir en 2 listas + 3 widgets"
```

### PASO 3.2 — home_page.dart (580 → 280 líneas)

```
ARCHIVO: lib/pages/home_page.dart (580 líneas)

PROBLEMA:
- Cards de inicio
- Estadísticas
- Botones de acción
- Mensajes de bienvenida

SOLUCIÓN:
1. Crear lib/widgets/welcome_card.dart (80 líneas)
   - Saludo personalizado
   - Avatar

2. Crear lib/widgets/stats_card.dart (100 líneas)
   - 3 cards de estadísticas
   - Lugares visitados, recompensas, etc.

3. Crear lib/widgets/action_buttons.dart (80 líneas)
   - Botones de acciones rápidas

4. home_page.dart (280 líneas)
   - Scaffold
   - welcome_card
   - stats_card
   - action_buttons
   - Scroll view

COMMIT:
git add lib/pages/home_page.dart lib/widgets/welcome_card.dart lib/widgets/stats_card.dart lib/widgets/action_buttons.dart
git commit -m "refactor: home_page — dividir en cards reutilizables"
```

### PASO 3.3 — place_detail_page.dart (483 → 280 líneas)

```
ARCHIVO: lib/pages/place_detail_page.dart (483 líneas)

PROBLEMA:
- Header con imagen
- Información del lugar
- Mapa
- Botón de escaneo
- Reseñas/calificaciones

SOLUCIÓN:
1. Crear lib/widgets/place_header.dart (120 líneas)
   - Imagen + nombre + rating

2. Crear lib/widgets/place_info.dart (100 líneas)
   - Descripción, dirección, teléfono, horario

3. Crear lib/widgets/place_action_buttons.dart (80 líneas)
   - Botón escanear, compartir, favorito

4. place_detail_page.dart (280 líneas)
   - Estructura general
   - Llamadas a servicios
   - Composición de widgets

COMMIT:
git add lib/pages/place_detail_page.dart lib/widgets/place_header.dart lib/widgets/place_info.dart lib/widgets/place_action_buttons.dart
git commit -m "refactor: place_detail_page — dividir en componentes reutilizables"
```

### PASO 3.4 — places_page.dart (405 → 250 líneas)

```
ARCHIVO: lib/pages/places_page.dart (405 líneas)

PROBLEMA:
- Tabs de categorías
- Filtros
- Lista de lugares
- Búsqueda

SOLUCIÓN:
1. Crear lib/widgets/place_category_tabs.dart (80 líneas)
   - Tabs de categorías

2. Crear lib/widgets/places_filter_bar.dart (100 líneas)
   - Filtros, búsqueda

3. Crear lib/widgets/places_list.dart (120 líneas)
   - GridView o ListView de places

4. places_page.dart (250 líneas)
   - Composición de widgets
   - Manejo de estado de filtros

COMMIT:
git add lib/pages/places_page.dart lib/widgets/place_category_tabs.dart lib/widgets/places_filter_bar.dart lib/widgets/places_list.dart
git commit -m "refactor: places_page — dividir en tabs + filtros + lista"
```

### PASO 3.5 — profile_page.dart (340 → 220 líneas)

```
ARCHIVO: lib/pages/profile_page.dart (340 líneas)

PROBLEMA:
- Datos de usuario
- Perfil avatar
- Botones de acciones
- Información sensible

SOLUCIÓN:
1. Crear lib/widgets/user_profile_header.dart (100 líneas)
   - Avatar, nombre, email

2. Crear lib/widgets/profile_actions.dart (80 líneas)
   - Botones cambiar contraseña, editar, logout

3. profile_page.dart (220 líneas)
   - Composición
   - Navegación

COMMIT:
git add lib/pages/profile_page.dart lib/widgets/user_profile_header.dart lib/widgets/profile_actions.dart
git commit -m "refactor: profile_page — dividir en header + acciones"
```

**VERIFICACIÓN FASE 3:**
```bash
flutter analyze lib/
flutter build apk --debug

flutter run -d DEVICE_ID
# Testear: home, places, detalle, perfil, historial

git commit -m "refactor: FASE 3 completa — vistas principales optimizadas"
```

---

## FASE 4 — Páginas Menores y Optimización

### PASO 4.1 — success_page.dart (511 → 200 líneas)

```
ARCHIVO: lib/pages/success_page.dart (511 líneas)

HACER:
- Simplificar animaciones
- Extraer componentes visuales
- Máximo 200 líneas

COMMIT:
git add lib/pages/success_page.dart
git commit -m "refactor: success_page — simplificar animaciones"
```

### PASO 4.2 — scan_page.dart (245 → 200 líneas)

```
ARCHIVO: lib/pages/scan_page.dart (245 líneas)

HACER:
- Ya está bien, pequeñas optimizaciones
- Máximo 200 líneas
- Crear lib/widgets/qr_scanner_widget.dart si es necesario

COMMIT:
git add lib/pages/scan_page.dart
git commit -m "refactor: scan_page — extraer scanner a widget"
```

### PASO 4.3 — settings_page.dart (139 líneas)

```
ARCHIVO: lib/pages/settings_page.dart (139 líneas)

✅ YA ESTÁ BIEN — No tocar
```

### PASO 4.4 — about_page.dart (150 líneas)

```
ARCHIVO: lib/pages/about_page.dart (150 líneas)

✅ YA ESTÁ BIEN — No tocar
```

### PASO 4.5 — main_navigation.dart (179 líneas)

```
ARCHIVO: lib/pages/main_navigation.dart (179 líneas)

HACER:
- Crear lib/widgets/bottom_navigation_bar.dart (80 líneas)
- Extraer construcción del navbar

COMMIT:
git add lib/pages/main_navigation.dart lib/widgets/bottom_navigation_bar.dart
git commit -m "refactor: main_navigation — extraer navbar a widget"
```

**VERIFICACIÓN FINAL:**
```bash
flutter analyze lib/
# DEBE DAR: No issues found!

flutter build apk --debug
# DEBE COMPILAR SIN ERRORES

flutter run -d DEVICE_ID
# TESTEAR FLUJO COMPLETO:
# 1. Login
# 2. Ir a home
# 3. Explorar lugares
# 4. Ver detalle
# 5. Ver historial
# 6. Ir a perfil
# 7. Ver recompensas
# 8. Logout
```

---

## COMMIT FINAL Y PUSH

```bash
cd C:\Users\usuario\Documents\proyecto

# Ver todos los cambios
git log --oneline feat/nuevas-interfaces-app-movil | head -20

# Verificar que todo está limpio
git status

# Crear un commit final de resumen
git commit -m "refactor: REFACTORIZACIÓN COMPLETA — app móvil feature-first

- FASE 1: api_service monolítico → 5 servicios especializados
- FASE 2: login, register, forgot-password → componentes reutilizables
- FASE 3: history (808), home (580), places, detail → divididos en widgets
- FASE 4: Páginas menores y widgets base
- Resultado: Máximo 300 líneas por archivo, arquitectura mantenible
- flutter analyze: ✅ 0 errores
- flutter build apk --debug: ✅ Sin problemas"

# Push a la rama
git push origin feat/nuevas-interfaces-app-movil

# Verificar en GitHub
echo "Verifica: https://github.com/montesandres654321-ship-it/nova-project"
echo "Branch: feat/nuevas-interfaces-app-movil"
```

---

## PRÓXIMO PASO

Cuando termines TODA la refactorización:

1. Verifica en GitHub que todos los commits estén
2. Haz un `flutter analyze final` para confirmar
3. Reporta aquí: ✅ Refactorización completa
4. Entonces: Esperamos Figma → nuevas interfaces

---

*Plan generado: Septiembre 2026*  
*Rama: feat/nuevas-interfaces-app-movil*  
*Objetivo: Base limpia antes de nuevas funcionalidades*
