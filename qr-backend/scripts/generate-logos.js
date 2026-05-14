const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const BASE = path.join(__dirname, '../../');

// ── SVG del ícono cuadrado (1024x1024) ──────────────
const iconSVG = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
  <rect x="0" y="0" width="1024" height="1024" rx="196" fill="#06B6A4"/>

  <!-- QR esquina superior izquierda -->
  <rect x="112" y="100" width="236" height="236" rx="32" fill="none" stroke="white" stroke-width="36"/>
  <rect x="168" y="156" width="72" height="72" rx="12" fill="white"/>

  <!-- QR esquina superior derecha -->
  <rect x="676" y="100" width="236" height="236" rx="32" fill="none" stroke="white" stroke-width="36"/>
  <rect x="732" y="156" width="72" height="72" rx="12" fill="white"/>

  <!-- QR esquina inferior izquierda -->
  <rect x="112" y="440" width="236" height="236" rx="32" fill="none" stroke="white" stroke-width="36"/>
  <rect x="168" y="496" width="72" height="72" rx="12" fill="white"/>

  <!-- QR datos (zona derecha inferior) -->
  <rect x="680" y="450" width="48" height="48" rx="8" fill="white"/>
  <rect x="748" y="450" width="48" height="48" rx="8" fill="white"/>
  <rect x="816" y="450" width="88" height="48" rx="8" fill="white"/>
  <rect x="680" y="518" width="88" height="48" rx="8" fill="white"/>
  <rect x="788" y="518" width="116" height="48" rx="8" fill="white"/>
  <rect x="680" y="586" width="48" height="48" rx="8" fill="white"/>
  <rect x="748" y="586" width="96" height="48" rx="8" fill="white"/>
  <rect x="864" y="586" width="40" height="48" rx="8" fill="white"/>
  <rect x="680" y="648" width="112" height="40" rx="8" fill="white"/>
  <rect x="812" y="648" width="92" height="40" rx="8" fill="white"/>

  <!-- Línea separadora -->
  <rect x="100" y="740" width="824" height="6" rx="3" fill="rgba(255,255,255,0.3)"/>

  <!-- Texto NOVA -->
  <text x="512" y="860"
    text-anchor="middle"
    font-family="Arial Black, Arial, sans-serif"
    font-size="148"
    font-weight="900"
    fill="white"
    letter-spacing="24">NOVA</text>

  <!-- Texto App -->
  <text x="512" y="960"
    text-anchor="middle"
    font-family="Arial, sans-serif"
    font-size="80"
    font-weight="400"
    fill="rgba(255,255,255,0.85)"
    letter-spacing="12">App</text>
</svg>`;

// ── SVG logo horizontal (para dashboard header) ──────
const logoHorizontalSVG = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 80" width="520" height="80">
  <!-- Ícono cuadrado pequeño -->
  <rect x="0" y="4" width="72" height="72" rx="16" fill="#06B6A4"/>

  <!-- QR mini esquinas -->
  <rect x="9" y="12" width="22" height="22" rx="4" fill="none" stroke="white" stroke-width="4"/>
  <rect x="14" y="17" width="7" height="7" rx="1.5" fill="white"/>
  <rect x="41" y="12" width="22" height="22" rx="4" fill="none" stroke="white" stroke-width="4"/>
  <rect x="46" y="17" width="7" height="7" rx="1.5" fill="white"/>
  <rect x="9" y="42" width="22" height="22" rx="4" fill="none" stroke="white" stroke-width="4"/>
  <rect x="14" y="47" width="7" height="7" rx="1.5" fill="white"/>
  <rect x="41" y="42" width="5" height="5" rx="1" fill="white"/>
  <rect x="49" y="42" width="5" height="5" rx="1" fill="white"/>
  <rect x="57" y="42" width="7" height="5" rx="1" fill="white"/>
  <rect x="41" y="50" width="28" height="5" rx="1" fill="white"/>
  <rect x="41" y="58" width="22" height="5" rx="1" fill="white"/>
  <rect x="5" y="70" width="62" height="1" rx="0.5" fill="rgba(255,255,255,0.4)"/>
  <text x="36" y="79" text-anchor="middle" font-family="Arial Black,Arial" font-size="11" font-weight="900" fill="white" letter-spacing="3">NOVA</text>

  <!-- Separador vertical -->
  <rect x="88" y="16" width="1.5" height="48" rx="1" fill="#E5E7EB"/>

  <!-- Texto NOVA grande -->
  <text x="104" y="46"
    text-anchor="start"
    font-family="Arial Black, Arial, sans-serif"
    font-size="32"
    font-weight="900"
    fill="#06B6A4"
    letter-spacing="3">NOVA</text>

  <!-- Texto App -->
  <text x="104" y="66"
    text-anchor="start"
    font-family="Arial, sans-serif"
    font-size="14"
    font-weight="400"
    fill="#888780"
    letter-spacing="1">App · Golfo de Morrosquillo</text>
</svg>`;

// ── SVG logo horizontal blanco (para navbar teal) ──
const logoWhiteSVG = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 72" width="320" height="72">
  <rect x="0" y="4" width="64" height="64" rx="16" fill="rgba(255,255,255,0.2)"/>
  <rect x="8" y="11" width="20" height="20" rx="3" fill="none" stroke="white" stroke-width="3.5"/>
  <rect x="12" y="15" width="6" height="6" rx="1" fill="white"/>
  <rect x="36" y="11" width="20" height="20" rx="3" fill="none" stroke="white" stroke-width="3.5"/>
  <rect x="40" y="15" width="6" height="6" rx="1" fill="white"/>
  <rect x="8" y="39" width="20" height="20" rx="3" fill="none" stroke="white" stroke-width="3.5"/>
  <rect x="12" y="43" width="6" height="6" rx="1" fill="white"/>
  <rect x="36" y="39" width="24" height="4" rx="1" fill="white"/>
  <rect x="36" y="46" width="28" height="4" rx="1" fill="white"/>
  <rect x="36" y="53" width="20" height="4" rx="1" fill="white"/>
  <text x="82" y="38" text-anchor="start" font-family="Arial Black,Arial" font-size="28" font-weight="900" fill="white" letter-spacing="3">NOVA</text>
  <text x="82" y="60" text-anchor="start" font-family="Arial,sans-serif" font-size="15" font-weight="400" fill="rgba(255,255,255,0.8)" letter-spacing="1">App</text>
</svg>`;

async function generate() {
  console.log('\n Generando assets de identidad NOVA App\n');

  // Crear directorios
  const dirs = [
    BASE + 'nova_app/assets/icon',
    BASE + 'nova_dashboard/web/icons',
    BASE + 'nova_dashboard/assets/images',
  ];
  dirs.forEach(d => fs.mkdirSync(d, { recursive: true }));

  // 1. Icono SVG fuente (para Flutter)
  fs.writeFileSync(BASE + 'nova_app/assets/icon/app_icon.svg', iconSVG);
  console.log('OK app_icon.svg creado');

  // 2. PNG 1024x1024 para Play Store
  await sharp(Buffer.from(iconSVG))
    .resize(1024, 1024)
    .png()
    .toFile(BASE + 'nova_app/assets/icon/app_icon_1024.png');
  console.log('OK app_icon_1024.png (Play Store)');

  // 3. PNG 512x512 para web
  await sharp(Buffer.from(iconSVG))
    .resize(512, 512)
    .png()
    .toFile(BASE + 'nova_dashboard/web/icons/Icon-512.png');
  console.log('OK Icon-512.png');

  // 4. PNG 192x192 para web
  await sharp(Buffer.from(iconSVG))
    .resize(192, 192)
    .png()
    .toFile(BASE + 'nova_dashboard/web/icons/Icon-192.png');
  console.log('OK Icon-192.png');

  // 5. Favicon 32x32
  await sharp(Buffer.from(iconSVG))
    .resize(32, 32)
    .png()
    .toFile(BASE + 'nova_dashboard/web/favicon.png');
  console.log('OK favicon.png (32x32)');

  // 6. Logo horizontal SVG
  fs.writeFileSync(
    BASE + 'nova_dashboard/assets/images/logo_horizontal.svg',
    logoHorizontalSVG
  );
  console.log('OK logo_horizontal.svg');

  // 7. Logo blanco SVG (para navbar)
  fs.writeFileSync(
    BASE + 'nova_dashboard/assets/images/logo_white.svg',
    logoWhiteSVG
  );
  console.log('OK logo_white.svg');

  // 8. PNG del logo horizontal
  await sharp(Buffer.from(logoHorizontalSVG))
    .resize(520, 80)
    .png()
    .toFile(BASE + 'nova_dashboard/assets/images/logo_horizontal.png');
  console.log('OK logo_horizontal.png');

  console.log('\nTodos los assets generados correctamente\n');
  console.log('Archivos creados:');
  console.log('  nova_app/assets/icon/app_icon_1024.png  <- Play Store');
  console.log('  nova_app/assets/icon/app_icon.svg       <- Flutter launcher');
  console.log('  nova_dashboard/web/favicon.png           <- Favicon navegador');
  console.log('  nova_dashboard/web/icons/Icon-192.png    <- PWA');
  console.log('  nova_dashboard/web/icons/Icon-512.png    <- PWA');
  console.log('  nova_dashboard/assets/images/logo_*.svg  <- Dashboard');
}

generate().catch(e => {
  console.error('ERROR:', e.message);
  process.exit(1);
});
