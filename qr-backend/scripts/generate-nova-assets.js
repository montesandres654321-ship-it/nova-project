const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const BASE = path.join(__dirname, '../../');

// ════════════════════════════════════════════════════
// SVG VERSIÓN DETALLADA — Play Store 1024px
// ════════════════════════════════════════════════════
const iconDetailed = `<svg xmlns="http://www.w3.org/2000/svg"
  viewBox="0 0 1024 1024" width="1024" height="1024">

  <!-- Fondo teal -->
  <rect width="1024" height="1024" rx="220" fill="#06B6A4"/>

  <!-- Ola principal -->
  <path d="M0 680 Q120 630 256 660 Q390 690 512 650
           Q634 610 768 640 Q890 668 1024 630
           L1024 870 Q890 840 768 858 Q634 878 512 852
           Q390 828 256 850 Q120 870 0 845 Z"
        fill="#0369A1"/>

  <!-- Ola secundaria -->
  <path d="M0 720 Q128 695 256 710 Q384 728 512 700
           Q640 672 768 692 Q896 712 1024 690
           L1024 900 L0 900 Z"
        fill="#0EA5E9" opacity="0.45"/>

  <!-- Espuma olas -->
  <circle cx="200" cy="668" r="18" fill="white" opacity="0.7"/>
  <circle cx="222" cy="648" r="11" fill="white" opacity="0.5"/>
  <circle cx="620" cy="645" r="16" fill="white" opacity="0.7"/>
  <circle cx="644" cy="662" r="10" fill="white" opacity="0.5"/>
  <circle cx="840" cy="655" r="14" fill="white" opacity="0.6"/>

  <!-- Base isla -->
  <ellipse cx="512" cy="630" rx="360" ry="82" fill="#134E4A"/>

  <!-- Colina izquierda -->
  <ellipse cx="360" cy="520" rx="168" ry="158" fill="white" opacity="0.93"/>
  <!-- Colina central (más alta) -->
  <ellipse cx="512" cy="478" rx="198" ry="185" fill="white"/>
  <!-- Colina derecha -->
  <ellipse cx="656" cy="528" rx="148" ry="138" fill="white" opacity="0.93"/>

  <!-- Sombras base colinas -->
  <ellipse cx="360" cy="574" rx="168" ry="60" fill="rgba(19,78,74,0.4)"/>
  <ellipse cx="512" cy="586" rx="198" ry="62" fill="rgba(19,78,74,0.38)"/>
  <ellipse cx="656" cy="576" rx="148" ry="55" fill="rgba(19,78,74,0.4)"/>

  <!-- Palmera — tronco -->
  <path d="M672 632 Q678 554 668 476 Q663 436 672 392"
        stroke="rgba(255,255,255,0.95)" stroke-width="28"
        fill="none" stroke-linecap="round"/>

  <!-- Palmera — hoja izquierda principal -->
  <path d="M672 392 Q592 300 524 332"
        stroke="white" stroke-width="32"
        fill="none" stroke-linecap="round"/>

  <!-- Palmera — hoja derecha principal -->
  <path d="M672 392 Q756 300 818 328"
        stroke="white" stroke-width="32"
        fill="none" stroke-linecap="round"/>

  <!-- Palmera — hoja superior -->
  <path d="M672 392 Q680 300 668 252"
        stroke="white" stroke-width="28"
        fill="none" stroke-linecap="round"/>

  <!-- Palmera — hoja secundaria izquierda -->
  <path d="M672 392 Q620 316 578 344"
        stroke="rgba(255,255,255,0.72)" stroke-width="22"
        fill="none" stroke-linecap="round"/>

  <!-- Palmera — hoja secundaria derecha -->
  <path d="M672 392 Q730 320 774 350"
        stroke="rgba(255,255,255,0.72)" stroke-width="22"
        fill="none" stroke-linecap="round"/>

  <!-- Cocos -->
  <circle cx="644" cy="418" r="24" fill="rgba(255,255,255,0.52)"/>
  <circle cx="658" cy="400" r="18" fill="rgba(255,255,255,0.38)"/>

  <!-- Línea separadora sutil -->
  <rect x="80" y="940" width="864" height="6" rx="3"
        fill="rgba(255,255,255,0.25)"/>

  <!-- Texto NOVA -->
  <text x="512" y="970"
        text-anchor="middle"
        font-family="Arial Black, Arial, sans-serif"
        font-size="152"
        font-weight="900"
        fill="white"
        letter-spacing="28">NOVA</text>

  <!-- Texto App -->
  <text x="512" y="1010"
        text-anchor="middle"
        font-family="Arial, sans-serif"
        font-size="72"
        font-weight="300"
        fill="rgba(255,255,255,0.82)"
        letter-spacing="18">App</text>
</svg>`;

// ════════════════════════════════════════════════════
// SVG VERSIÓN SIMPLIFICADA — Launcher/Favicon
// Trazos gruesos, sin detalles finos, legible a 32px
// ════════════════════════════════════════════════════
const iconSimple = `<svg xmlns="http://www.w3.org/2000/svg"
  viewBox="0 0 512 512" width="512" height="512">

  <!-- Fondo teal -->
  <rect width="512" height="512" rx="110" fill="#06B6A4"/>

  <!-- Ola simple y limpia -->
  <path d="M0 330 Q128 290 256 318 Q384 346 512 308
           L512 512 L0 512 Z"
        fill="#0369A1"/>

  <!-- Base isla sólida -->
  <ellipse cx="256" cy="310" rx="192" ry="42" fill="#134E4A"/>

  <!-- 3 colinas grandes y limpias -->
  <ellipse cx="174" cy="240" rx="100" ry="95" fill="white"/>
  <ellipse cx="264" cy="220" rx="120" ry="112" fill="white"/>
  <ellipse cx="346" cy="248" rx="90" ry="84" fill="white"/>

  <!-- Sombra base única -->
  <ellipse cx="256" cy="294" rx="190" ry="38"
           fill="rgba(19,78,74,0.48)"/>

  <!-- Palmera — tronco muy grueso -->
  <path d="M348 312 Q352 255 346 204"
        stroke="rgba(255,255,255,0.96)" stroke-width="22"
        fill="none" stroke-linecap="round"/>

  <!-- Solo 3 hojas gruesas y cortas -->
  <path d="M346 204 Q290 148 248 166"
        stroke="white" stroke-width="26"
        fill="none" stroke-linecap="round"/>
  <path d="M346 204 Q402 148 436 166"
        stroke="white" stroke-width="26"
        fill="none" stroke-linecap="round"/>
  <path d="M346 204 Q350 148 344 122"
        stroke="white" stroke-width="22"
        fill="none" stroke-linecap="round"/>
</svg>`;

// ════════════════════════════════════════════════════
// SVG LOGO HORIZONTAL — Header dashboard fondo blanco
// ════════════════════════════════════════════════════
const logoHorizontal = `<svg xmlns="http://www.w3.org/2000/svg"
  viewBox="0 0 480 72" width="480" height="72">

  <!-- Ícono cuadrado pequeño -->
  <rect x="0" y="0" width="72" height="72" rx="16" fill="#06B6A4"/>

  <!-- Ola mini -->
  <path d="M0 46 Q18 38 36 43 Q54 48 72 40 L72 72 L0 72 Z"
        fill="#0369A1"/>

  <!-- Base isla mini -->
  <ellipse cx="36" cy="44" rx="28" ry="6" fill="#134E4A"/>

  <!-- Colinas mini -->
  <ellipse cx="24" cy="34" rx="14" ry="13" fill="white"/>
  <ellipse cx="37" cy="30" rx="17" ry="16" fill="white"/>
  <ellipse cx="49" cy="35" rx="13" ry="12" fill="white"/>

  <!-- Sombra mini -->
  <ellipse cx="36" cy="41" rx="27" ry="5" fill="rgba(19,78,74,0.45)"/>

  <!-- Palmera mini — solo tronco + 3 hojas -->
  <path d="M50 44 Q51 35 49 28"
        stroke="rgba(255,255,255,0.95)" stroke-width="3.5"
        fill="none" stroke-linecap="round"/>
  <path d="M49 28 Q42 20 37 23"
        stroke="white" stroke-width="4"
        fill="none" stroke-linecap="round"/>
  <path d="M49 28 Q56 20 61 23"
        stroke="white" stroke-width="4"
        fill="none" stroke-linecap="round"/>
  <path d="M49 28 Q50 20 49 16"
        stroke="white" stroke-width="3.5"
        fill="none" stroke-linecap="round"/>

  <!-- Separador vertical -->
  <rect x="88" y="12" width="1.5" height="48" rx="1" fill="#E5E7EB"/>

  <!-- Texto NOVA -->
  <text x="106" y="44"
        font-family="Arial Black, Arial, sans-serif"
        font-size="30"
        font-weight="900"
        fill="#06B6A4"
        letter-spacing="3">NOVA</text>

  <!-- Texto App subtítulo -->
  <text x="108" y="62"
        font-family="Arial, sans-serif"
        font-size="13"
        font-weight="400"
        fill="#888780"
        letter-spacing="1">App · Golfo de Morrosquillo</text>
</svg>`;

// ════════════════════════════════════════════════════
// SVG LOGO BLANCO — Navbar teal
// ════════════════════════════════════════════════════
const logoWhite = `<svg xmlns="http://www.w3.org/2000/svg"
  viewBox="0 0 360 56" width="360" height="56">

  <!-- Ícono con fondo semitransparente -->
  <rect x="0" y="0" width="56" height="56" rx="13"
        fill="rgba(255,255,255,0.18)"/>

  <!-- Ola mini blanca -->
  <path d="M0 36 Q14 29 28 33 Q42 38 56 31 L56 56 L0 56 Z"
        fill="rgba(255,255,255,0.25)"/>

  <!-- Base isla -->
  <ellipse cx="28" cy="34" rx="22" ry="5" fill="rgba(255,255,255,0.4)"/>

  <!-- Colinas blancas -->
  <ellipse cx="18" cy="26" rx="11" ry="10" fill="white" opacity="0.88"/>
  <ellipse cx="29" cy="23" rx="13" ry="12" fill="white"/>
  <ellipse cx="39" cy="27" rx="10" ry="9" fill="white" opacity="0.88"/>

  <!-- Palmera blanca -->
  <path d="M40 34 Q41 27 39 21"
        stroke="white" stroke-width="3"
        fill="none" stroke-linecap="round"/>
  <path d="M39 21 Q33 14 28 17"
        stroke="white" stroke-width="3.5"
        fill="none" stroke-linecap="round"/>
  <path d="M39 21 Q45 14 50 17"
        stroke="white" stroke-width="3.5"
        fill="none" stroke-linecap="round"/>
  <path d="M39 21 Q40 14 39 11"
        stroke="white" stroke-width="3"
        fill="none" stroke-linecap="round"/>

  <!-- Texto NOVA blanco -->
  <text x="70" y="32"
        font-family="Arial Black, Arial, sans-serif"
        font-size="24"
        font-weight="900"
        fill="white"
        letter-spacing="3">NOVA</text>

  <!-- Texto App -->
  <text x="72" y="48"
        font-family="Arial, sans-serif"
        font-size="13"
        font-weight="300"
        fill="rgba(255,255,255,0.8)"
        letter-spacing="2">App</text>
</svg>`;

async function generateAll() {
  console.log('\n🎨 Generando identidad visual NOVA App\n');
  console.log('='.repeat(50));

  const outputs = [
    // ── App móvil ──────────────────────────────────
    {
      svg: iconDetailed,
      out: BASE + 'nova_app/assets/icon/app_icon_1024.png',
      w: 1024, h: 1024,
      desc: 'Ícono Play Store (1024×1024)'
    },
    {
      svg: iconSimple,
      out: BASE + 'nova_app/assets/icon/app_icon_512.png',
      w: 512, h: 512,
      desc: 'Ícono 512px'
    },
    {
      svg: iconSimple,
      out: BASE + 'nova_app/assets/icon/app_icon_192.png',
      w: 192, h: 192,
      desc: 'Ícono launcher 192px'
    },
    {
      svg: iconSimple,
      out: BASE + 'nova_app/assets/icon/app_icon_48.png',
      w: 48, h: 48,
      desc: 'Ícono launcher 48px'
    },
    // ── Dashboard web ──────────────────────────────
    {
      svg: iconSimple,
      out: BASE + 'nova_dashboard/web/favicon.png',
      w: 32, h: 32,
      desc: 'Favicon navegador (32×32)'
    },
    {
      svg: iconSimple,
      out: BASE + 'nova_dashboard/web/icons/Icon-192.png',
      w: 192, h: 192,
      desc: 'PWA Icon 192'
    },
    {
      svg: iconSimple,
      out: BASE + 'nova_dashboard/web/icons/Icon-512.png',
      w: 512, h: 512,
      desc: 'PWA Icon 512'
    },
    {
      svg: iconSimple,
      out: BASE + 'nova_dashboard/web/icons/Icon-maskable-192.png',
      w: 192, h: 192,
      desc: 'PWA Maskable 192'
    },
  ];

  // Generar PNGs
  for (const item of outputs) {
    try {
      fs.mkdirSync(path.dirname(item.out), { recursive: true });
      await sharp(Buffer.from(item.svg))
        .resize(item.w, item.h)
        .png()
        .toFile(item.out);
      console.log(`✅ ${item.desc}`);
    } catch (e) {
      console.error(`❌ ${item.desc}: ${e.message}`);
    }
  }

  // Guardar SVGs fuente
  const svgFiles = [
    { svg: iconDetailed, out: BASE + 'nova_app/assets/icon/app_icon_detailed.svg', desc: 'SVG detallado (fuente)' },
    { svg: iconSimple,   out: BASE + 'nova_app/assets/icon/app_icon_simple.svg',   desc: 'SVG simplificado (fuente)' },
    { svg: logoHorizontal, out: BASE + 'nova_dashboard/assets/images/logo_horizontal.svg', desc: 'Logo horizontal SVG' },
    { svg: logoWhite,    out: BASE + 'nova_dashboard/assets/images/logo_white.svg', desc: 'Logo blanco SVG' },
  ];

  for (const f of svgFiles) {
    fs.mkdirSync(path.dirname(f.out), { recursive: true });
    fs.writeFileSync(f.out, f.svg);
    console.log(`✅ ${f.desc}`);
  }

  // Logo horizontal PNG
  try {
    await sharp(Buffer.from(logoHorizontal))
      .resize(480, 72)
      .png()
      .toFile(BASE + 'nova_dashboard/assets/images/logo_horizontal.png');
    console.log('✅ Logo horizontal PNG');
  } catch (e) {
    console.error('❌ Logo horizontal PNG:', e.message);
  }

  console.log('\n' + '='.repeat(50));
  console.log('🎉 Assets generados\n');
}

generateAll().catch(e => {
  console.error('❌ Error fatal:', e.message);
  process.exit(1);
});
