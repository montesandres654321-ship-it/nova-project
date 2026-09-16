---
name: nova-charts
description: "Sistema de visualización de datos de NOVA App para que las gráficas del dashboard y de la app se vean profesionales y comuniquen con claridad. Usa este skill SIEMPRE que se cree, modifique o revise cualquier gráfica, chart, visualización, KPI, indicador, dashboard analítico, reporte de datos, o cuando se muestre información numérica del observatorio turístico (escaneos, visitas, recompensas, gasto, municipios, tendencias). Es distinto del skill nova-design: nova-design cubre interfaces (botones, tarjetas, layout); nova-charts cubre la ciencia de visualizar datos (qué gráfica usar, cómo reducir ruido, color con significado, manejo de pocos datos). Aplican los dos juntos cuando una pantalla tiene gráficas."
---

# NOVA App — Sistema de visualización de datos

Complementa a nova-design. Mientras nova-design cubre CÓMO SE VE la interfaz,
nova-charts cubre CÓMO SE ENTIENDE el dato. Ambos aplican a la vez en pantallas
con gráficas.

Principio maestro: **la gráfica correcta, con el mínimo de tinta, contando una
historia clara.** Cada elemento de una gráfica debe justificar su existencia.

---

## 1. Elegir el tipo correcto de gráfica (lo más importante)

El error más grave es usar el tipo equivocado. Regla según la pregunta que responde:

| Qué quiero mostrar | Tipo correcto | Ejemplo en NOVA |
|--------------------|---------------|-----------------|
| Cambio en el tiempo | **Línea** (o área) | Escaneos por día, estacionalidad, recompensas por día |
| Comparar categorías | **Barras** (horizontal si son muchas) | Top lugares, visitas por municipio |
| Proporción del total | **Dona / barra apilada** | Tipos de lugar, canjeadas vs pendientes |
| Un solo valor clave | **KPI grande** (número, no gráfica) | Total escaneos, total turistas |
| Distribución por hora | **Barras** | Horario pico de escaneos |
| Ubicación geográfica | **Mapa de calor** | Concentración de visitas en el Golfo |

Reglas duras:
- **Dona/pie SOLO para 2-4 categorías.** Para comparar 5+ elementos → barras SIEMPRE.
  Una dona con 8 lugares es ilegible.
- **Barras horizontales** cuando las etiquetas son largas (nombres de lugares) o hay
  muchas categorías — se leen mejor que verticales apretadas.
- **Línea** solo para datos ordenados en el tiempo. Nunca línea para categorías sueltas.
- Si es un solo número, NO hacer gráfica: mostrar un KPI grande con contexto.

---

## 2. Reducir el ruido (data-ink ratio)

Maximizar la tinta dedicada al dato, minimizar la decoración. Quitar todo lo que
no ayude a entender:

- **Grillas:** quitar las verticales. Las horizontales, muy sutiles (`#EEF2F2`) o
  ninguna. Nunca grillas oscuras o gruesas.
- **Ejes:** líneas de eje discretas o ausentes. Texto de eje en secundario
  `#5C7371`, 11-12px, sin negrita.
- **Sin marco/borde** alrededor del área de la gráfica.
- **Sin fondo de color** en el área de trazado (fondo transparente o blanco).
- **Menos marcas de eje:** no etiquetar cada punto; mostrar los relevantes (inicio,
  fin, picos) y espaciar el resto.
- Regla mental: si borro este elemento, ¿se entiende igual el dato? Si sí, bórralo.

---

## 3. Color con propósito (no decorativo)

El color debe CODIFICAR significado, no rellenar:

- **Una serie = un color de marca** (teal `#06B6A4`). No usar un color distinto por
  cada barra si todas son lo mismo.
- **Colores semánticos** para estados: verde `#16A34A` (éxito/canjeada), ámbar
  `#D97706` (pendiente), rojo `#DC2626` (inactivo).
- **Resaltar el dato clave, atenuar el resto:** el lugar #1 en teal fuerte, los demás
  en gris o teal claro. Dirige el ojo a lo importante.
- **Nunca el arcoíris por defecto** de la librería (cada categoría un color aleatorio).
- Para secuencias (mapa de calor): degradado de un solo color, de claro a teal oscuro.
- Máximo 3-4 colores por gráfica. Más colores = más ruido.

---

## 4. Títulos que comunican y etiquetado

- **El título dice la conclusión, no solo el tema** cuando se puede:
  - Genérico (evitar): "Escaneos por día"
  - Mejor: "Los fines de semana concentran la mayoría de visitas"
  - Si no hay una conclusión clara, un título descriptivo limpio está bien.
- **Etiquetas directas sobre el dato** cuando el espacio lo permite: poner el valor
  encima de la barra o al final de la línea, en vez de obligar a leer el eje.
- **Leyenda solo si hay varias series.** Para una sola serie, la leyenda sobra.
- **Subtítulo con contexto:** período, unidad, fuente ("Últimos 30 días · escaneos").

---

## 5. Formato de números y contexto

- **Miles con separador:** `1.247` no `1247` (formato es-CO: punto para miles).
- **Decimales controlados:** máximo 1-2 cuando aportan; enteros cuando no.
- **Números grandes abreviados** si aplica: `1,2 mil`, `3,4 M`.
- **Unidades claras:** "escaneos", "visitas", "COP" — nunca un número pelado sin contexto.
- **Referencias comparativas** cuando existan: `+20% vs. mes anterior`, `sobre meta`,
  promedio. Un número con comparación comunica el triple.
- **Porcentajes:** cuando el total importa, mostrar % junto al absoluto.

---

## 6. Manejo de pocos datos (CRÍTICO para este proyecto)

NOVA App hoy tiene pocos datos (8 escaneos). Una gráfica con 1-2 puntos se ve pobre
y poco profesional. Reglas:

- **Menos de ~3-4 puntos de datos:** NO forzar una gráfica. Mostrar el número grande
  (KPI) con su contexto, o una lista simple.
- **Umbral de gráfica:** definir un mínimo de datos para que la gráfica aparezca.
  Debajo del umbral, mostrar mensaje: "Aún no hay suficientes datos para mostrar
  tendencias" con el número disponible.
- **Nunca** una gráfica de línea con 2 puntos (parece un palo), ni barras con 1 sola
  barra (se ve vacío).
- A medida que se acumulen datos reales, las gráficas ganan sentido. Diseñar para
  ambos estados: pocos datos (KPI) y muchos datos (gráfica).

---

## 7. Estados de la gráfica

Toda gráfica maneja tres estados, nunca romperse:
- **Cargando:** skeleton o indicador teal, no un espacio en blanco.
- **Vacío / sin datos:** ícono tenue + mensaje amable ("Sin datos en este período").
  Nunca una gráfica en blanco sin explicación.
- **Error:** mensaje claro + botón "Reintentar".

---

## 8. Consistencia entre gráficas

- **Un solo estilo** en todo el dashboard: si las líneas son curvas (suaves) en una
  gráfica, que lo sean en todas. Mismo grosor de línea, mismo estilo de punto.
- **Mismos colores para lo mismo:** si "canjeada" es verde en una gráfica, es verde
  en todas.
- **Mismo formato de fecha y número** en todas las gráficas.
- **Tooltips uniformes:** mismo estilo (fondo de marca, no el default de la librería)
  en todas.
- Cada gráfica dentro de una tarjeta (según nova-design) con su título arriba.

---

## 9. KPIs (indicadores de un solo número)

- Número grande: 28-36px, peso 700, color teal o de estado.
- Etiqueta debajo: 12-13px, peso 400-500, secundario.
- Contraste de tamaño número/etiqueta: mínimo 2x (el número domina).
- Ícono en círculo de color suave opcional, a un lado.
- Contexto/tendencia si existe: `+12%` en verde o rojo según suba o baje.
- Si es clickeable, navega a su detalle (cursor pointer, hover sutil).

---

## 10. Checklist antes de dar una gráfica por terminada
1. ¿El tipo de gráfica es el correcto para lo que se quiere mostrar?
2. ¿Es una dona con 5+ categorías? → cambiar a barras.
3. ¿Quité grillas pesadas, marcos y fondos innecesarios (data-ink)?
4. ¿El color codifica significado, no es arcoíris decorativo?
5. ¿El dato clave está resaltado y el contexto atenuado?
6. ¿El título comunica (idealmente una conclusión)?
7. ¿Los números tienen formato legible y contexto/comparación?
8. ¿Manejo bien el caso de pocos datos (KPI en vez de gráfica pobre)?
9. ¿Tiene estados de carga, vacío y error?
10. ¿Es consistente con las demás gráficas (estilo, color, formato)?
11. ¿Un funcionario entendería el mensaje en 5 segundos sin explicación?

## Al crear o modificar gráficas
- Aplicar también nova-design (la gráfica vive dentro de una tarjeta con estilo).
- Respetar reglas técnicas de nova-flutter (no romper build ni web_build).
- Usar la librería de charts que ya tiene el proyecto; personalizarla, no cambiarla.
- Cambios quirúrgicos: mejorar el estilo sin romper los datos que ya se muestran.
