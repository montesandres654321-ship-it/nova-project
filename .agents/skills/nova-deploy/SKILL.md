---
name: nova-deploy
description: "Flujo de pruebas y despliegue de NOVA App. Usa este skill cuando se vaya a hacer commit, push, desplegar a producción, generar un APK, reconstruir el dashboard web, o cuando se prepare cualquier cambio para subir al repositorio. Contiene el checklist obligatorio antes de desplegar, el formato de mensajes de commit, y cómo verificar que Render y Vercel redespliegan correctamente."
---

# NOVA App — Flujo de despliegue

## Principio de oro
**Nunca subir a producción algo que no se probó localmente.**
Render (backend) y Vercel (dashboard) redespliegan automáticamente al hacer push a `main`.
Un push roto = producción rota.

## Checklist antes de CADA push
1. ¿El cambio se probó localmente y funciona?
2. ¿`flutter analyze` da 0 errores? (si es Flutter)
3. ¿El backend arranca sin errores? (`npm start`, si es backend)
4. Si tocaste el dashboard: ¿hiciste el `xcopy` a `web_build/`?
5. ¿No estás subiendo `.env` ni archivos sensibles?
6. ¿El mensaje de commit describe claramente el cambio?

## Despliegue del backend
```bash
git add qr-backend/...   # solo los archivos tocados
git commit -m "fix: descripción clara del cambio"
git push origin main
# Render redespliega automático. Verificar en el dashboard de Render.
```

## Despliegue del dashboard (Flutter Web)
```bash
cd nova_dashboard
flutter build web --dart-define=API_URL=https://nova-project-xzpe.onrender.com --release
xcopy /E /I /Y nova_dashboard\build\web\* nova_dashboard\web_build\
git add nova_dashboard/web_build/
git commit -m "chore: rebuild web + descripción"
git push origin main
# Vercel redespliega automático al detectar el push.
```

## Generación de APK (app móvil)
```bash
cd nova_app
flutter clean && flutter pub get && flutter analyze   # verificar 0 errores
flutter build apk --dart-define=API_URL=https://nova-project-xzpe.onrender.com --release
# APK en: nova_app\build\app\outputs\flutter-apk\app-release.apk
# Actualizar 'version:' en pubspec.yaml antes de builds nuevos.
```

## Formato de mensajes de commit
Usar prefijos consistentes:
- `feat:` nueva funcionalidad
- `fix:` corrección de bug
- `chore:` tareas de mantenimiento (rebuild, bump version)
- `refactor:` reorganización sin cambio funcional
- `docs:` documentación

Ejemplo: `feat: filtro por subregiones en dashboard de reportes`

## Migraciones de base de datos (Prisma)
Delicado en Supabase free tier. Si un cambio requiere migración:
1. Probar la migración primero en local con copia de la BD.
2. Verificar que no rompe datos existentes.
3. Solo entonces aplicar en producción.
```bash
npx prisma migrate dev --name "descripcion_del_cambio"
```

## Después de desplegar
- Verificar que el backend responde (probar un endpoint clave).
- Verificar que el dashboard carga en la URL de Vercel.
- Reportar el commit hash del cambio desplegado.

## Reglas absolutas
- ❌ NUNCA `git push` sin probar local.
- ❌ NUNCA subir `.env`.
- ❌ NUNCA editar `web_build/` a mano.
- ✅ SIEMPRE hacer `xcopy` tras build web.
- ✅ SIEMPRE mostrar el commit hash al terminar.
