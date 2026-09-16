---
name: nova-design
description: "Sistema de diseño de NOVA App para lograr interfaces profesionales y consistentes en sus DOS componentes: la app móvil Flutter (que usa el turista) y el dashboard Flutter Web (que usan administradores y la gobernación). Usa este skill SIEMPRE que se cree o modifique cualquier interfaz, pantalla, widget, componente visual, color, tipografía, espaciado o layout en nova_app/ o nova_dashboard/. Contiene la paleta de color, la jerarquía tipográfica, la escala de espaciado, los componentes estándar (botones, tarjetas, badges, inputs, gráficas) y las reglas de identidad institucional que hacen que el proyecto se vea serio y confiable para entes gubernamentales."
---

# NOVA App — Sistema de diseño

Aplica a los DOS componentes del proyecto:
- **App móvil** (`nova_app/`) — la usa el TURISTA. Prioridad: simple, amigable, táctil.
- **Dashboard web** (`nova_dashboard/`) — lo usan ADMINISTRADORES y la GOBERNACIÓN.
  Prioridad: profesional, denso en datos, confiable.

Objetivo: que ambos se vean como un producto institucional serio, no como un
proyecto estudiantil. Consistencia visual = percepción de calidad.

## Principio rector
Construir SOBRE el estilo que ya existe (teal, tarjetas redondeadas, badges),
no reinventar. Estandarizar lo que hoy es inconsistente. Cuando dudes, elige la
opción más sobria y limpia — menos decoración, más orden.

---

## 1. Sistema de color

Color de marca (teal) y neutros. Modo claro en ambos componentes.

| Rol | Hex | Uso |
|-----|-----|-----|
| Primary (teal marca) | `#06B6A4` | Botones principales, elementos activos, marca |
| Primary oscuro | `#048577` | Hover/presionado del primary, textos sobre claro |
| Primary claro | `#E6F7F5` | Fondos suaves, tints, chips seleccionados |
| Fondo app | `#FFFFFF` | Fondo base de pantallas |
| Fondo secundario | `#F5F7F8` | Fondos de sección, tarjetas anidadas |
| Superficie tarjeta | `#FFFFFF` | Tarjetas sobre fondo secundario |
| Borde sutil | `#E2E8E9` | Bordes de tarjetas e inputs |
| Texto principal | `#1A2B2A` | Títulos y cuerpo |
| Texto secundario | `#5C7371` | Subtítulos, descripciones, labels |
| Texto tenue | `#94A9A7` | Placeholders, pistas |

Colores de estado (semánticos):
| Estado | Hex | Uso |
|--------|-----|-----|
| Éxito | `#16A34A` | Activo, canjeada, confirmado (verde) |
| Advertencia | `#D97706` | Pendiente, atención (ámbar) |
| Error | `#DC2626` | Inactivo, error, eliminar (rojo) |
| Info | `#2563EB` | Etiquetas informativas (azul) |

Reglas de color:
- NUNCA improvisar tonos fuera de esta paleta. Si falta un color, derivarlo de estos.
- Texto sobre fondo teal: siempre blanco `#FFFFFF`.
- Texto sobre fondos de color suave: usar el tono oscuro de esa familia, nunca negro puro.
- Badges de estado: fondo tint claro + texto del color fuerte (ej: fondo verde claro + texto verde).

---

## 2. Tipografía

Una sola familia sans-serif en ambos componentes (la que ya usa Flutter por defecto,
o Inter/Roboto si se define). Jerarquía por tamaño y peso, no por fuentes distintas.

| Nivel | Tamaño | Peso | Uso |
|-------|--------|------|-----|
| Título de pantalla | 24-28px | 700 (bold) | Encabezado principal de cada vista |
| Título de sección | 18-20px | 600 (semibold) | Secciones dentro de una pantalla |
| Subtítulo | 16px | 600 | Nombres de tarjetas, ítems |
| Cuerpo | 14-15px | 400 | Texto normal |
| Etiqueta / caption | 12-13px | 500 | Badges, metadatos, pistas |

Reglas tipográficas:
- Máximo 2 pesos por pantalla (ej: 400 y 600). No mezclar 5 pesos distintos.
- Contraste mínimo AA: texto principal sobre fondo claro siempre legible.
- Sentence case en títulos y botones (no TODO MAYÚSCULAS, no Title Case Forzado).
- No reducir texto por debajo de 12px.

---

## 3. Espaciado y layout

Escala de espaciado fija — SIEMPRE múltiplos de 4. Nunca valores al azar.

| Token | Valor | Uso |
|-------|-------|-----|
| xs | 4px | Separación mínima entre elementos pegados |
| sm | 8px | Padding interno pequeño, gap entre chips |
| md | 16px | Padding estándar de tarjetas, gap entre ítems |
| lg | 24px | Separación entre secciones |
| xl | 32px | Márgenes generosos, respiración |

Reglas de layout:
- Margen mínimo del borde de pantalla: 16px (app), 24px (dashboard).
- Padding interno de tarjetas: 16px.
- Gap entre tarjetas: 12-16px.
- Tarjetas: radio de esquina 12px, borde sutil `#E2E8E9`, sombra muy ligera
  (opacidad ~0.06, blur 8px, offset 2px). Nunca sombras duras.
- **Dashboard:** en pantallas anchas, aprovechar el espacio. NUNCA dejar el
  contenido en una columna angosta centrada con 70% vacío (error actual del
  perfil). Usar layout de 2 columnas o grillas cuando el ancho > 800px.
- **App móvil:** una columna, contenido a lo ancho con márgenes de 16px.
- Dejar aire: no llenar cada pixel. El espacio en blanco comunica orden.

---

## 4. Componentes estándar

### Botones
- **Primario:** fondo teal `#06B6A4`, texto blanco, radio 8px, padding 12x20px,
  peso 600. Hover/presionado: `#048577`.
- **Secundario:** fondo blanco, borde teal, texto teal.
- **Peligro:** texto/borde rojo `#DC2626` (para eliminar, cerrar sesión).
- **De texto:** sin fondo, solo texto teal (para acciones terciarias).
- Altura mínima táctil en app: 44px.

### Tarjetas
- Fondo blanco, radio 12px, borde `#E2E8E9`, sombra ligera.
- Padding interno 16px.
- Si tiene encabezado de color (como las tarjetas de "Cómo funciona"), el header
  usa teal con texto blanco.

### Badges de estado
- Formato pill (radio alto), padding 4x10px, texto 12px peso 500.
- Activo/Éxito: fondo `#E6F7F5` o verde claro + texto verde `#16A34A`.
- Pendiente: fondo ámbar claro + texto `#D97706`.
- Inactivo/Error: fondo rojo claro + texto `#DC2626`.

### Inputs
- Fondo `#F5F7F8` o blanco, borde `#E2E8E9`, radio 8px, padding 12px.
- Foco: borde teal. Placeholder en texto tenue `#94A9A7`.
- Ícono a la izquierda cuando aporte contexto (correo, teléfono, candado).

### Gráficas (dashboard)
- Usar el teal y sus variantes como color primario de series.
- Estados de color coherentes con la paleta (verde éxito, ámbar pendiente).
- Ejes en texto secundario `#5C7371`, líneas de grilla muy sutiles.
- Cada gráfica dentro de una tarjeta con título de sección arriba.
- NUNCA gráficas sin título ni contexto.

### KPI cards (dashboard)
- Número grande (28-32px bold, en teal o color de estado) + label pequeño debajo.
- Ícono en círculo de color suave a un lado.
- Si son clickeables, que naveguen a su sección (indicar con cursor/hover).

### Estados vacíos y de carga
- Vacío: ícono tenue centrado + mensaje amable ("Aún no hay visitantes").
  Nunca una pantalla en blanco sin explicación.
- Carga: indicador teal centrado (CircularProgressIndicator).
- Error: ícono + mensaje claro + botón "Reintentar".

---

## 4bis. Elevación por niveles (clave para verse profesional)

El error más común: usar borde + sombra + fondo distinto TODO a la vez en cada
tarjeta. Eso genera ruido visual y se ve amateur. Solución: un sistema de 3 niveles
de profundidad, y cada elemento pertenece a UNO.

| Nivel | Qué es | Cómo se separa | NO usar |
|-------|--------|----------------|---------|
| 0 — Fondo | Página base | Color `#F5F7F8` | Sin bordes ni sombra |
| 1 — Tarjeta | Contenido sobre el fondo | Fondo blanco + sombra MUY sutil (opacidad 0.05, blur 12px, offset 0,2) | No agregar borde además de la sombra |
| 2 — Flotante | Modales, menús, popovers | Sombra más marcada (opacidad 0.12, blur 24px) | — |

Regla de oro: **una tarjeta se separa por sombra O por borde, nunca por ambos.**
Preferir sombra sutil sobre borde. El borde `#E2E8E9` solo para inputs y divisores,
no para tarjetas que ya tienen sombra.

Menos líneas divisorias: separar secciones con espacio (24px) en vez de líneas.
Una línea divisoria solo cuando el espacio no basta para agrupar.

## 4ter. Contraste jerárquico (los datos importantes gritan)

En KPIs, gráficas y tarjetas de dato, el elemento principal debe DOMINAR:
- El número/dato: grande (28-36px), peso 700, color fuerte (teal o estado).
- Su etiqueta: pequeña (12-13px), peso 400-500, color secundario `#5C7371`.
- La diferencia de tamaño entre ambos debe ser notoria (mínimo 2x).

Ejemplo KPI correcto: `22` a 32px bold teal, y debajo `Total escaneos` a 12px tenue.
Ejemplo incorrecto: ambos a tamaño similar — se ve plano y sin intención.

## 4quater. Gráficas con identidad propia (dashboard)

Las gráficas "de librería por defecto" delatan un proyecto amateur. Personalizarlas:
- **Color:** usar solo la paleta NOVA (teal primario + variantes + estados).
  Una serie = un color de marca, no el arcoíris por defecto.
- **Ejes:** texto en secundario `#5C7371`, tamaño 11-12px. Sin negritas.
- **Grillas:** quitar las líneas de grilla verticales; las horizontales muy sutiles
  (`#E2E8E9` o más claro) o ninguna. Nada de grillas oscuras y pesadas.
- **Sin bordes de marco** alrededor del área de la gráfica.
- **Relleno de área** (en gráficas de línea): degradado sutil del teal a transparente.
- **Un solo estilo** de gráfica en todo el dashboard: si las líneas son suaves
  (curved) en una, que lo sean en todas.
- **Tooltips:** con fondo de marca, no el default gris de la librería.
- Cada gráfica SIEMPRE dentro de una tarjeta con su título de sección arriba.

## 4quinquies. Micro-interacciones y feedback

Los detalles que se sienten "premium":
- **Botones:** cambio de color al presionar/hover (teal → teal oscuro), transición
  suave (~150ms). En la app, feedback táctil (InkWell/ripple).
- **Tarjetas clickeables:** elevación sutil al hover (dashboard) — la sombra crece
  un poco. Cursor pointer.
- **Transiciones de pantalla:** suaves, no bruscas (~200-300ms).
- **Carga:** nunca pantalla congelada. Mostrar indicador teal o skeleton.
- **Confirmaciones:** feedback visual inmediato tras cada acción (snackbar, cambio
  de estado, checkmark).
- **Propósito ante decoración:** toda animación comunica algo (que algo cargó, que
  se guardó, que se puede tocar). Nunca animar solo por adornar.
- Respetar reduced-motion cuando aplique.

## 4sexies. Iconografía unificada

- UN solo set de íconos en cada componente (Material Icons de Flutter, o un set
  outline consistente). No mezclar estilos (algunos rellenos, otros de línea).
- Mismo grosor de trazo en todos.
- Tamaños estándar: 20px inline, 24px en botones/acciones, 32px en headers/estados vacíos.
- Íconos con significado consistente: el mismo ícono siempre representa lo mismo
  en toda la app (un QR siempre igual, un pin de ubicación siempre igual).
- Íconos sobre círculo de color suave cuando encabezan una sección o KPI.

## 5. Identidad institucional

Lo que hace que se sienta "de gobierno serio":
- Sobriedad: pocos colores, mucho orden, nada de degradados chillones ni animaciones excesivas.
- Consistencia: el mismo botón se ve igual en toda la app. El mismo badge, igual.
- Iconografía: un solo set de íconos (los de Flutter/Material o un set outline
  consistente). No mezclar estilos de íconos.
- Marca NOVA presente pero discreta (logo en encabezados, no invasivo).
- Datos claros: en el dashboard, los números y gráficas son los protagonistas,
  no la decoración.
- Accesibilidad: contraste suficiente, áreas táctiles amplias en la app.

---

## 5bis. Errores que hacen ver amateur — EVITAR SIEMPRE

Estos son los patrones concretos que delatan un diseño no profesional. Nunca hacerlos:

- ❌ Borde + sombra + fondo de color, los tres a la vez, en una misma tarjeta.
- ❌ Contenido en columna angosta centrada con 60-70% de la pantalla vacía (dashboard).
- ❌ Números de KPI del mismo tamaño que sus etiquetas (falta de jerarquía).
- ❌ Gráficas con el estilo por defecto de la librería (colores arcoíris, grillas pesadas).
- ❌ Espaciados distintos entre pantallas equivalentes (unos 12px, otros 20px sin razón).
- ❌ Mezclar estilos de íconos (unos rellenos, otros de línea, distintos grosores).
- ❌ Sombras duras y oscuras (se ven pesadas y viejas). Usar sombras sutiles.
- ❌ Demasiados colores compitiendo. Máximo teal + neutros + 1-2 estados por pantalla.
- ❌ Texto pegado a los bordes de tarjetas o pantalla (siempre padding mínimo 16px).
- ❌ Pantallas sin estado vacío/carga/error (dejan al usuario confundido).
- ❌ TODO EN MAYÚSCULAS o Title Case Forzado en títulos y botones.
- ❌ Botones sin feedback al presionar (parecen rotos).
- ❌ Múltiples tonos de gris o de teal sin sistema (elegir los de la paleta y punto).
- ❌ Alinear elementos "a ojo" en vez de a la grilla de 8px.

## 5ter. La grilla de 8px (orden invisible)

TODO se alinea a una grilla de 8px. Posiciones, tamaños, espaciados: múltiplos de 8
(o de 4 para ajustes finos). Esto crea el orden que el ojo percibe como profesional
aunque no lo note conscientemente.
- Elementos equivalentes en distintas pantallas: mismos márgenes exactos.
- Columnas y tarjetas alineadas entre sí, no desfasadas.
- Cuando algo "se ve raro" pero no sabes por qué, casi siempre es que no está en la grilla.

## 6. Checklist antes de dar una pantalla por terminada
1. ¿Usa solo colores de la paleta (teal + neutros + estados)?
2. ¿Todo está alineado a la grilla de 8px?
3. ¿La tipografía respeta la jerarquía (máx 2 pesos) y hay contraste fuerte
   entre datos principales y etiquetas?
4. ¿Las tarjetas usan UN solo método de separación (sombra sutil), no borde+sombra+fondo?
5. ¿Aprovecha el ancho disponible, sin columnas angostas con vacío (dashboard)?
6. ¿Los botones, badges e inputs siguen los estándares?
7. ¿Las gráficas usan la paleta propia, sin estilo de librería por defecto?
8. ¿Los íconos son de un solo set, mismo grosor y tamaño coherente?
9. ¿Hay micro-interacciones (feedback al tocar, hover, transiciones suaves)?
10. ¿Hay estados de vacío, carga y error bien resueltos?
11. ¿Repasé la lista de errores anti-amateur (5bis) y no cometo ninguno?
12. ¿Se ve consistente con las demás pantallas del mismo componente?
13. ¿Un funcionario de gobierno lo percibiría como profesional y confiable?

## Al aplicar diseño
- Respetar las reglas técnicas de nova-flutter (no romper build, web_build, etc.).
- Cambios visuales quirúrgicos: no romper la funcionalidad existente.
- Si una pantalla actual viola el sistema (ej: perfil angosto), corregirla hacia
  el estándar sin alterar su lógica.
- Mantener coherencia entre app y dashboard: misma paleta y componentes, adaptados
  a cada contexto (táctil vs. denso en datos).
