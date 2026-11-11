// PHOS branding. Legacy export names preserve compatibility with desktop apps.
import { createElement as h } from 'react';
import { View, Image } from '@lordos/runtime';
const SIZES = [16, 32, 64, 128, 256, 512, 1024];
export function LordOSLogo({ size: s = 64 }) {
  const px = SIZES.find((z) => z >= s * 2) || 1024;
  return h(Image, { src: `asset:icons/phos-icon-${px}.png`, style: { width: s, height: s } });
}
export function LordOSGlyph({ size: s = 16 }) { return h(LordOSLogo, { size: s }); }
export function LordOSWordmark({ size: s = 28 }) {
  // Original PNG is 3:1. A white plate keeps dark lettering readable on all themes.
  const width = s * 8;
  return h(View, { style: { backgroundColor: '#ffffff', borderRadius: s * 0.22, overflow: 'hidden' } },
    h(Image, { src: 'asset:icons/phos-original.png', style: { width, height: width / 3 } }));
}
