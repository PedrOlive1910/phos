// Render the PHOS panda avatar for UI, Plymouth and GRUB.
// The user's original full PNG is kept unchanged.
import sharp from 'sharp';
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const root = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const icon = await fs.readFile(path.join(root, 'assets/mascot/panda-avatar-128.png'));
// icons/ is included by mkdeb.sh and is accessible to sandboxed system apps.
await fs.copyFile(path.join(root, 'assets/brand/phos-original.png'), path.join(root, 'assets/icons/phos-original.png'));
async function render(rel, size) {
  const dest = path.join(root, rel);
  await fs.mkdir(path.dirname(dest), { recursive: true });
  await sharp(icon).resize(size, size, { fit: 'contain', background: '#00000000' }).png().toFile(dest);
}
for (const size of [16, 32, 64, 128, 256, 512, 1024]) {
  await render(`assets/icons/phos-icon-${size}.png`, size);
  await render(`assets/icons/lordos-icon-${size}.png`, size);
}
for (const tone of ['light', 'dark']) {
  for (const size of [16, 32]) await render(`assets/icons/lordos-glyph-${tone}-${size}.png`, size);
}
await render('assets/icons/lordos-crown.png', 256);
await render('assets/icons/lordos-crown-512.png', 512);
await render('tools/boot/plymouth/lordos/phos-symbol.png', 112);
await render('tools/boot/plymouth/lordos/phos-symbol@2x.png', 224);
await render('tools/iso/grub/lordos/phos-symbol.png', 96);
console.log('PHOS panda icons rendered; supplied panda logotype preserved.');
