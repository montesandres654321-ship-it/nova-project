# Cómo instalar los skills de NOVA App en Claude Code

Tienes 9 skills listos, cada uno en su carpeta con un archivo `SKILL.md`:

- `nova-context/`      → Contexto maestro (stack, URLs, reglas, estructura)
- `nova-backend/`      → Reglas del backend Node.js + Prisma
- `nova-flutter/`      → Reglas del frontend Flutter (dashboard y app)
- `nova-deploy/`       → Flujo de pruebas y despliegue
- `nova-observatorio/` → Conocimiento estratégico del observatorio turístico

---

## PASO 1 — Ubica la carpeta de skills de tu proyecto

Los skills de proyecto van en una carpeta `.claude/skills/` dentro de la raíz
de tu proyecto. Si no existe, créala.

En Windows (PowerShell o CMD), dentro de tu proyecto:
```
cd C:\Users\usuario\Documents\proyecto
mkdir .claude\skills
```

---

## PASO 2 — Copia las 5 carpetas de skills

Copia las carpetas `nova-context`, `nova-backend`, `nova-flutter`,
`nova-deploy` y `nova-observatorio` (cada una con su `SKILL.md` adentro)
dentro de `.claude\skills\`.

La estructura final debe quedar así:
```
proyecto/
└── .claude/
    └── skills/
        ├── nova-context/
        │   └── SKILL.md
        ├── nova-backend/
        │   └── SKILL.md
        ├── nova-flutter/
        │   └── SKILL.md
        ├── nova-deploy/
        │   └── SKILL.md
        └── nova-observatorio/
            └── SKILL.md
```

---

## PASO 3 — Verifica que Claude Code los detecta

Abre Claude Code en tu proyecto:
```
cd C:\Users\usuario\Documents\proyecto
claude
```

Escribe dentro de Claude Code:
```
/skills
```
Deberías ver los 5 skills listados. Se activan automáticamente cuando la tarea
lo requiere — no tienes que invocarlos manualmente.

---

## PASO 4 (opcional) — Súbelos al repositorio

Como están dentro del proyecto, viajan con el repo. Así tu compañera de equipo
(Daismy) también los tiene. Si quieres compartirlos:
```
git add .claude/skills/
git commit -m "chore: agregar skills de contexto NOVA App para Claude Code"
git push origin main
```

Si prefieres que NO se suban (uso personal), agrégalos a `.gitignore`:
```
.claude/skills/
```

---

## Cómo funcionan (para que entiendas)

- Cada skill tiene una `description` en su encabezado. Claude Code la lee y
  activa el skill SOLO cuando la tarea coincide. No consumen contexto si no aplican.
- Por ejemplo: si tocas un archivo de `qr-backend/routes/`, se activa
  `nova-backend`. Si preparas un despliegue, se activa `nova-deploy`.
- `nova-context` es el más general: se activa en casi cualquier tarea del proyecto.

---

## Cómo mantenerlos actualizados

Cuando cambie algo importante del proyecto (nueva regla, nuevo endpoint clave,
nueva URL), edita el `SKILL.md` correspondiente. Son archivos de texto normales.
Mantenerlos al día es lo que hace que Claude Code deje de cometer los mismos errores.
