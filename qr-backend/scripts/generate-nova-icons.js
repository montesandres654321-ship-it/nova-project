const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const BASE = path.join(__dirname, '../../');

// ════════════════════════════════════════════════════
// SVG DETALLADO — Play Store 1024px (con texto NOVA)
// ════════════════════════════════════════════════════
const iconDetailed = `<svg xmlns="http://www.w3.org/2000/svg"
  viewBox="0 0 1024 1024" width="1024" height="1024">

  <!-- Fondo degradado teal -->
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0ED2C0"/>
      <stop offset="100%" stop-color="#0891B2"/>
    </linearGradient>
  </defs>
  <rect width="1024" height="1024" rx="210" fill="url(#bg)"/>

  <!-- Ola principal -->
  <path d="M0 700 Q128 650 256 678 Q384 706 512 670
           Q640 634 768 660 Q896 686 1024 650
           L1024 880 Q896 856 768 872
           Q640 888 512 864 Q384 840 256 860
           Q128 880 0 858 Z"
        fill="#0369A1"/>

  <!-- Ola secundaria suave -->
  <path d="M0 740 Q128 718 256 732
           Q384 748 512 720 Q640 694 768 714
           Q896 734 1024 712 L1024 900 L0 900 Z"
        fill="#0EA5E9" opacity="0.45"/>

  <!-- Espuma olas -->
  <circle cx="220" cy="704" r="20" fill="white" opacity="0.65"/>
  <circle cx="244" cy="688" r="12" fill="white" opacity="0.45"/>
  <circle cx="720" cy="672" r="18" fill="white" opacity="0.65"/>
  <circle cx="748" cy="690" r="11" fill="white" opacity="0.45"/>

  <!-- Base isla -->
  <ellipse cx="512" cy="642" rx="370" ry="78" fill="#134E4A"/>

  <!-- Colinas blancas -->
  <ellipse cx="370" cy="526" rx="172" ry="162" fill="white" opacity="0.96"/>
  <ellipse cx="520" cy="492" rx="204" ry="184" fill="white"/>
  <ellipse cx="668" cy="534" rx="144" ry="132" fill="white" opacity="0.96"/>

  <!-- Sombra base colinas -->
  <ellipse cx="512" cy="614" rx="362" ry="58"
           fill="rgba(19,78,74,0.42)"/>

  <!-- Palmera tronco grueso -->
  <path d="M678 642 Q682 554 674 474 Q670 434 678 392"
        stroke="rgba(255,255,255,0.95)" stroke-width="28"
        fill="none" stroke-linecap="round"/>

  <!-- Hoja izquierda principal -->
  <path d="M678 392 Q594 294 520 330"
        stroke="white" stroke-width="36"
        fill="none" stroke-linecap="round"/>

  <!-- Hoja derecha principal -->
  <path d="M678 392 Q762 294 828 326"
        stroke="white" stroke-width="36"
        fill="none" stroke-linecap="round"/>

  <!-- Hoja superior -->
  <path d="M678 392 Q684 292 676 238"
        stroke="white" stroke-width="30"
        fill="none" stroke-linecap="round"/>

  <!-- Hoja izquierda secundaria -->
  <path d="M678 392 Q620 310 572 340"
        stroke="rgba(255,255,255,0.75)" stroke-width="24"
        fill="none" stroke-linecap="round"/>

  <!-- Hoja derecha secundaria -->
  <path d="M678 392 Q738 314 784 344"
        stroke="rgba(255,255,255,0.75)" stroke-width="24"
        fill="none" stroke-linecap="round"/>

  <!-- Coco -->
  <circle cx="654" cy="420" r="26" fill="rgba(255,255,255,0.5)"/>
  <circle cx="670" cy="402" r="18" fill="rgba(255,255,255,0.35)"/>

  <!-- Línea separadora -->
  <rect x="80" y="920" width="864" height="5" rx="2.5"
        fill="rgba(255,255,255,0.22)"/>

  <!-- Texto NOVA -->
  <text x="512" y="980"
        text-anchor="middle"
        font-family="Arial Black, Arial, sans-serif"
        font-size="140" font-weight="900"
        fill="white" letter-spacing="22">NOVA</text>

</svg>`;

// ════════════════════════════════════════════════════
// SVG SIMPLIFICADO — Launcher/Favicon (sin texto)
// Trazos muy gruesos para verse bien a 48px
// ════════════════════════════════════════════════════
const iconSimple = `<svg xmlns="http://www.w3.org/2000/svg"
  viewBox="0 0 512 512" width="512" height="512">

  <defs>
    <linearGradient id="bg2" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0ED2C0"/>
      <stop offset="100%" stop-color="#0891B2"/>
    </linearGradient>
  </defs>
  <rect width="512" height="512" rx="105" fill="url(#bg2)"/>

  <!-- Ola simple y limpia -->
  <path d="M0 338 Q128 302 256 326
           Q384 350 512 318 L512 512 L0 512 Z"
        fill="#0369A1"/>

  <!-- Ola suave -->
  <path d="M0 360 Q128 344 256 358
           Q384 374 512 356 L512 512 L0 512 Z"
        fill="#0EA5E9" opacity="0.4"/>

  <!-- Base isla sólida -->
  <ellipse cx="256" cy="318" rx="195" ry="40" fill="#134E4A"/>

  <!-- 3 colinas grandes y limpias -->
  <ellipse cx="172" cy="240" rx="104" ry="98" fill="white"/>
  <ellipse cx="266" cy="218" rx="124" ry="114" fill="white"/>
  <ellipse cx="352" cy="248" rx="92" ry="86" fill="white"/>

  <!-- Sombra base -->
  <ellipse cx="256" cy="302" rx="190" ry="34"
           fill="rgba(19,78,74,0.45)"/>

  <!-- Tronco palmera MUY grueso -->
  <path d="M354 320 Q358 262 352 210"
        stroke="rgba(255,255,255,0.96)" stroke-width="22"
        fill="none" stroke-linecap="round"/>

  <!-- Solo 3 hojas MUY gruesas -->
  <path d="M352 210 Q296 148 252 170"
        stroke="white" stroke-width="28"
        fill="none" stroke-linecap="round"/>
  <path d="M352 210 Q408 148 448 168"
        stroke="white" stroke-width="28"
        fill="none" stroke-linecap="round"/>
  <path d="M352 210 Q356 146 350 118"
        stroke="white" stroke-width="24"
        fill="none" stroke-linecap="round"/>

</svg>`;

// ════════════════════════════════════════════════════
// SVG LOGO BLANCO — Navbar teal del dashboard
// ════════════════════════════════════════════════════
const logoWhite = `<svg xmlns="http://www.w3.org/2000/svg"
  viewBox="0 0 300 56" width="300" height="56">

  <!-- Ícono fondo semitransparente -->
  <rect x="0" y="2" width="52" height="52" rx="13"
        fill="rgba(255,255,255,0.18)"/>

  <!-- Ola mini -->
  <path d="M0 37 Q13 31 26 35 Q39 39 52 33 L52 54 L0 54 Z"
        fill="rgba(255,255,255,0.25)"/>

  <!-- Base isla mini -->
  <ellipse cx="26" cy="36" rx="21" ry="5"
           fill="rgba(255,255,255,0.38)"/>

  <!-- Colinas blancas mini -->
  <ellipse cx="16" cy="27" rx="10" ry="9" fill="white" opacity="0.86"/>
  <ellipse cx="27" cy="24" rx="12" ry="11" fill="white"/>
  <ellipse cx="37" cy="28" rx="9" ry="8" fill="white" opacity="0.86"/>

  <!-- Sombra mini -->
  <ellipse cx="26" cy="33" rx="20" ry="4"
           fill="rgba(255,255,255,0.3)"/>

  <!-- Palmera mini — tronco + 3 hojas -->
  <path d="M38 36 Q39 28 37 21"
        stroke="rgba(255,255,255,0.95)" stroke-width="2.8"
        fill="none" stroke-linecap="round"/>
  <path d="M37 21 Q31 14 26 17"
        stroke="white" stroke-width="3.5"
        fill="none" stroke-linecap="round"/>
  <path d="M37 21 Q43 14 48 17"
        stroke="white" stroke-width="3.5"
        fill="none" stroke-linecap="round"/>
  <path d="M37 21 Q38 14 37 10"
        stroke="white" stroke-width="3"
        fill="none" stroke-linecap="round"/>

  <!-- Texto NOVA -->
  <text x="64" y="30"
        font-family="Arial Black, Arial, sans-serif"
        font-size="20" font-weight="900"
        fill="white" letter-spacing="2">NOVA</text>

  <!-- Texto App subtítulo -->
  <text x="66" y="46"
        font-family="Arial, sans-serif"
        font-size="12" font-weight="300"
        fill="rgba(255,255,255,0.78)" letter-spacing="1">App</text>

</svg>`;

// ════════════════════════════════════════════════════
// SVG LOGO COLOR — Fondo blanco (login page)
// ════════════════════════════════════════════════════
const logoColor = `<svg xmlns="http://www.w3.org/2000/svg"
  viewBox="0 0 300 56" width="300" height="56">

  <defs>
    <linearGradient id="iconBg" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0ED2C0"/>
      <stop offset="100%" stop-color="#0891B2"/>
    </linearGradient>
  </defs>

  <!-- Ícono con fondo teal -->
  <rect x="0" y="2" width="52" height="52" rx="13" fill="url(#iconBg)"/>

  <!-- Ola mini -->
  <path d="M0 37 Q13 31 26 35 Q39 39 52 33 L52 54 L0 54 Z"
        fill="#0369A1"/>

  <!-- Base isla -->
  <ellipse cx="26" cy="36" rx="21" ry="5" fill="#134E4A"/>

  <!-- Colinas -->
  <ellipse cx="16" cy="27" rx="10" ry="9" fill="white" opacity="0.95"/>
  <ellipse cx="27" cy="24" rx="12" ry="11" fill="white"/>
  <ellipse cx="37" cy="28" rx="9" ry="8" fill="white" opacity="0.95"/>
  <ellipse cx="26" cy="33" rx="20" ry="4" fill="rgba(19,78,74,0.4)"/>

  <!-- Palmera -->
  <path d="M38 36 Q39 28 37 21"
        stroke="rgba(255,255,255,0.95)" stroke-width="2.8"
        fill="none" stroke-linecap="round"/>
  <path d="M37 21 Q31 14 26 17"
        stroke="white" stroke-width="3.5"
        fill="none" stroke-linecap="round"/>
  <path d="M37 21 Q43 14 48 17"
        stroke="white" stroke-width="3.5"
        fill="none" stroke-linecap="round"/>
  <path d="M37 21 Q38 14 37 10"
        stroke="white" stroke-width="3"
        fill="none" stroke-linecap="round"/>

  <!-- Texto NOVA teal -->
  <text x="64" y="30"
        font-family="Arial Black, Arial, sans-serif"
        font-size="20" font-weight="900"
        fill="#06B6A4" letter-spacing="2">NOVA</text>

  <!-- Subtítulo gris -->
  <text x="66" y="46"
        font-family="Arial, sans-serif"
        font-size="11" font-weight="400"
        fill="#888780" letter-spacing="1">App · Golfo de Morrosquillo</text>

</svg>`;

async function generateAll() {
  console.log('\n🎨 Generando íconos y logos NOVA App\n');
  console.log('='.repeat(50));

  const outputs = [
    // App móvil
    {
      svg: iconDetailed,
      out: BASE + 'nova_app/assets/icon/app_icon_1024.png',
      w: 1024, h: 1024,
      desc: '✅ App ícono 1024px (Play Store)'
    },
    {
      svg: iconSimple,
      out: BASE + 'nova_app/assets/icon/app_icon_512.png',
      w: 512, h: 512,
      desc: '✅ App ícono 512px'
    },
    {
      svg: iconSimple,
      out: BASE + 'nova_app/assets/icon/app_icon_192.png',
      w: 192, h: 192,
      desc: '✅ App ícono 192px (launcher)'
    },
    {
      svg: iconSimple,
      out: BASE + 'nova_app/assets/icon/app_icon_48.png',
      w: 48, h: 48,
      desc: '✅ App ícono 48px'
    },
    // Dashboard web
    {
      svg: iconSimple,
      out: BASE + 'nova_dashboard/web/favicon.png',
      w: 32, h: 32,
      desc: '✅ Favicon 32px'
    },
    {
      svg: iconSimple,
      out: BASE + 'nova_dashboard/web/icons/Icon-192.png',
      w: 192, h: 192,
      desc: '✅ PWA Icon 192'
    },
    {
      svg: iconSimple,
      out: BASE + 'nova_dashboard/web/icons/Icon-512.png',
      w: 512, h: 512,
      desc: '✅ PWA Icon 512'
    },
    {
      svg: iconSimple,
      out: BASE + 'nova_dashboard/web/icons/Icon-maskable-192.png',
      w: 192, h: 192,
      desc: '✅ PWA Maskable 192'
    },
  ];

  for (const item of outputs) {
    try {
      fs.mkdirSync(path.dirname(item.out), { recursive: true });
      await sharp(Buffer.from(item.svg))
        .resize(item.w, item.h)
        .png()
        .toFile(item.out);
      console.log(item.desc);
    } catch (e) {
      console.error('❌ ' + item.desc + ':', e.message);
    }
  }

  // SVGs fuente
  const svgs = [
    {
      svg: iconDetailed,
      out: BASE + 'nova_app/assets/icon/app_icon_detailed.svg',
      desc: '✅ SVG detallado'
    },
    {
      svg: iconSimple,
      out: BASE + 'nova_app/assets/icon/app_icon_simple.svg',
      desc: '✅ SVG simplificado'
    },
    {
      svg: logoWhite,
      out: BASE + 'nova_dashboard/assets/images/logo_white.svg',
      desc: '✅ Logo blanco SVG'
    },
    {
      svg: logoColor,
      out: BASE + 'nova_dashboard/assets/images/logo_color.svg',
      desc: '✅ Logo color SVG'
    },
  ];

  for (const f of svgs) {
    fs.mkdirSync(path.dirname(f.out), { recursive: true });
    fs.writeFileSync(f.out, f.svg);
    console.log(f.desc);
  }

  // PNGs de logos
  try {
    await sharp(Buffer.from(logoWhite))
      .resize(300, 56).png()
      .toFile(BASE + 'nova_dashboard/assets/images/logo_white.png');
    console.log('✅ Logo blanco PNG');
  } catch(e) { console.error('❌ Logo blanco PNG:', e.message); }

  try {
    await sharp(Buffer.from(logoColor))
      .resize(300, 56).png()
      .toFile(BASE + 'nova_dashboard/assets/images/logo_color.png');
    console.log('✅ Logo color PNG');
  } catch(e) { console.error('❌ Logo color PNG:', e.message); }

  console.log('\n' + '='.repeat(50));
  console.log('🎉 Generación completada\n');
}

generateAll().catch(e => {
  console.error('❌ Error fatal:', e.message);
  process.exit(1);
});
