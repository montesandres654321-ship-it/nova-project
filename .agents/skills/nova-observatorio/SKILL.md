---
name: nova-observatorio
description: "Conocimiento estratégico para convertir NOVA App en el Observatorio Turístico Departamental de Sucre. Usa este skill cuando se diseñen o implementen funcionalidades nuevas relacionadas con analítica turística, indicadores, perfil del visitante, subregiones, gasto, satisfacción, reportes, o cuando se decida QUÉ datos capturar y POR QUÉ. Contiene las dimensiones de un observatorio turístico, el mapeo con los ejes del Plan Estratégico de Turismo de Sucre, las subregiones del departamento y los estándares nacionales SITUR/PorTuColombia."
---

# NOVA App — Observatorio Turístico (dominio estratégico)

## Visión
NOVA App no es "una app de turismo". Es la base de un **Observatorio Turístico
Departamental (SITUR)** para Sucre, alineado con el Eje 5 del Plan Estratégico de
Turismo del departamento y con el sistema nacional PorTuColombia (antes CITUR).

Ventaja única: los observatorios en Colombia miden con encuestas manuales.
NOVA App captura datos **automáticamente** vía QR en cada visita. Ese es el
diferencial que hay que explotar y proteger en cada decisión de diseño.

## Las 6 dimensiones de un observatorio
Al diseñar cualquier funcionalidad nueva, ubicarla en una de estas dimensiones:

1. **DEMANDA** — quién visita: procedencia, edad, motivo de viaje, tipo
   (turista que pernocta vs. excursionista de día), frecuencia, repetición.
2. **TERRITORIO** — dónde: subregión, mapa de calor, capacidad de carga,
   rutas temáticas. Indicador estrella: **% de visitas fuera del Golfo**.
3. **OFERTA** — qué establecimientos: tipo, capacidad, formalización (RNT),
   distintivos de calidad (bandera azul).
4. **IMPACTO ECONÓMICO** — cuánto mueve: gasto promedio estimado, estacionalidad,
   derrama por subregión. (Lo que más convence a la gobernación.)
5. **SATISFACCIÓN** — calificación del lugar (1-5), NPS del destino, comentarios.
6. **SEGURIDAD** — alertas de clima/estado del mar, números de emergencia
   (conecta con el Eje 4 del Plan).

## Subregiones de Sucre (para etiquetar lugares)
- **Golfo de Morrosquillo** (Tolú, Coveñas, San Onofre) — sol y playa, saturado.
- **Montes de María** — turismo de memoria, cultura, PDET.
- **Sabana** (Sincelejo y alrededores) — cultura sabanera, gaitas, gastronomía.
- **San Jorge** — ríos, naturaleza.
- **La Mojana** — ecosistemas de humedal, vulnerable al clima.

El Plan insiste en **descentralizar del Golfo**. Cualquier feature que ayude a
medir o promover las otras subregiones tiene alto valor político.

## Mapeo NOVA App ↔ Ejes del Plan de Sucre
| Funcionalidad | Eje del Plan |
|---------------|--------------|
| Dashboard analítico / SITUR | Eje 5 (Digital y datos) + Eje 2 (Ordenamiento) |
| Filtro y mapa por subregión | Eje 7 (Diversificación) |
| Alertas de seguridad/clima | Eje 4 (Seguridad y riesgo) |
| Verificación RNT y calidad | Eje 6 (Formalización) |
| Recompensas a comercio local | Eje 9 (Inclusión comunitaria) |

## Principio de diseño de captura de datos
No abrumar al turista. Regla de oro:
- **Al registrarse (una sola vez):** procedencia, edad, motivo → 3 campos máx.
- **Al escanear (cada vez):** solo calificación opcional de 1 tap.
- **Todo lo demás:** inferirlo de los datos que el sistema ya tiene.
Si el registro tiene 15 campos, nadie lo llena. Menos es más.

## Hoja de ruta de funcionalidades (orden sugerido)
1. **Perfil + subregiones** — base del observatorio, bajo esfuerzo.
2. **Exportación de reportes** (PDF/Excel) — convierte el dashboard en herramienta oficial.
3. **Satisfacción y calificación** — indicador que nadie más automatiza.
4. **Impacto económico y estacionalidad** — traduce turismo en pesos.
5. **Seguridad y alertas** — valor al turista + Eje 4.
6. **Formalización y RNT** — requiere convenio con Cámara de Comercio.

## Argumento de venta institucional
"NOVA App operativiza el Eje 5 del Plan Estratégico de Turismo de Sucre. Es el
primer paso hacia el Observatorio Turístico Departamental que el propio plan
identifica como cimiento habilitante del destino."

## Al implementar una funcionalidad nueva del observatorio
- Ubicarla en una de las 6 dimensiones.
- Verificar que respeta el principio de no abrumar al turista.
- Conectarla explícitamente con un eje del Plan (para justificar ante la gobernación).
- Seguir las reglas técnicas de los skills nova-backend y nova-flutter.
