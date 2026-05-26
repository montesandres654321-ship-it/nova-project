const sharp = require('sharp');
const fs = require('fs');
const path = require('path');
const BASE = path.join(__dirname, '../../');

const svgPath = BASE + 'nova_dashboard/assets/images/logo_nova.svg';
const svgBuffer = fs.readFileSync(svgPath);

async function run() {
  console.log('\n🎨 Generando logo definitivo NOVA App\n');

  const files = [
    {
      out: BASE + 'nova_app/assets/icon/app_icon_1024.png',
      w: 1024, h: 1024,
      desc: 'App icon 1024px (Play Store)'
    },
    {
      out: BASE + 'nova_app/assets/icon/app_icon_512.png',
      w: 512, h: 512,
      desc: 'App icon 512px'
    },
    {
      out: BASE + 'nova_app/assets/icon/app_icon_192.png',
      w: 192, h: 192,
      desc: 'App launcher 192px'
    },
    {
      out: BASE + 'nova_app/assets/icon/app_icon_48.png',
      w: 48, h: 48,
      desc: 'App launcher 48px'
    },
    {
      out: BASE + 'nova_dashboard/assets/icon/app_icon_192.png',
      w: 192, h: 192,
      desc: 'Dashboard icon 192px'
    },
    {
      out: BASE + 'nova_dashboard/web/favicon.png',
      w: 32, h: 32,
      desc: 'Favicon 32px'
    },
    {
      out: BASE + 'nova_dashboard/web/icons/Icon-192.png',
      w: 192, h: 192,
      desc: 'PWA Icon 192'
    },
    {
      out: BASE + 'nova_dashboard/web/icons/Icon-512.png',
      w: 512, h: 512,
      desc: 'PWA Icon 512'
    },
    {
      out: BASE + 'nova_dashboard/web/icons/Icon-maskable-192.png',
      w: 192, h: 192,
      desc: 'PWA Maskable 192'
    },
  ];

  for (const f of files) {
    try {
      fs.mkdirSync(path.dirname(f.out), { recursive: true });
      await sharp(svgBuffer)
        .resize(f.w, f.h)
        .png()
        .toFile(f.out);
      console.log('✅ ' + f.desc);
    } catch(e) {
      console.error('❌ ' + f.desc + ': ' + e.message);
    }
  }

  console.log('\n✅ Todos los assets generados\n');
}

run().catch(e => {
  console.error('Error fatal:', e.message);
  process.exit(1);
});
