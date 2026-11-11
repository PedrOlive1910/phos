// PHOS panda mascot. Legacy Lumo exports preserve application compatibility.
import { createElement as h } from 'react';
import { Image } from '@lordos/runtime';
import { t } from './i18n.js';

const POSES = new Set(['wave', 'shield', 'celebrate', 'confused', 'sleep', 'run']);

export function lumoSource(pose = 'confused', size = 96) {
  if (pose === 'avatar') return size <= 40 ? 'asset:mascot/panda-avatar-small-64.png' : 'asset:mascot/panda-avatar-128.png';
  return `asset:mascot/panda-${POSES.has(pose) ? pose : 'confused'}-256.png`;
}

export function Lumo({ pose = 'confused', size = 96, alt, style }) {
  return h(Image, {
    src: lumoSource(pose, size),
    alt: alt || t(`mascot.${POSES.has(pose) || pose === 'avatar' ? pose : 'confused'}`),
    style: [{ width: size, height: size }, style],
  });
}
