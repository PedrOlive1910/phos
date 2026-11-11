// Slice the generated 4x2 mascot sheet into the UI's square PNG assets.
// No AI service is required to reproduce these files from the included sheet.
import sharp from 'sharp';
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const root = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const source = path.join(root, 'assets/brand/phos-panda-sheet.png');
const { width, height, hasAlpha } = await sharp(source).metadata();
if (!hasAlpha) throw new Error('Expected a transparent sprite sheet');
const poses = ['wave', 'shield', 'celebrate', 'confused', 'sleep', 'run', 'avatar', 'avatar-small'];
await fs.mkdir(path.join(root, 'assets/mascot'), { recursive: true });
for (let i = 0; i < poses.length; i++) {
  const pose = poses[i];
  const size = i < 6 ? 256 : i === 6 ? 128 : 64;
  const col = i % 4, row = Math.floor(i / 4);
  const left = Math.round(col * width / 4), top = Math.round(row * height / 2);
  const png = await sharp(source).extract({ left, top,
    width: Math.round((col + 1) * width / 4) - left, height: Math.round((row + 1) * height / 2) - top
  }).resize(size, size, { fit: 'contain', background: '#00000000' }).png().toBuffer();
  await fs.writeFile(path.join(root, `assets/mascot/panda-${pose}-${size}.png`), png);
  // Legacy callers (including the standalone imager) also get the new panda.
  await fs.writeFile(path.join(root, `assets/mascot/lumo-${pose}-${size}.png`), png);
}
console.log('PHOS panda: six poses and two avatars generated.');
