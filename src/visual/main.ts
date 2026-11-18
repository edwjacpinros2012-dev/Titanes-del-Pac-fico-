import Phaser from 'phaser';
import { BootScene } from './scenes/BootScene';
import { HangarScene } from './scenes/HangarScene';
import { CombatScene } from './scenes/CombatScene';
import './style.css';

const game = new Phaser.Game({
  type: Phaser.CANVAS,
  parent: 'game-root',
  backgroundColor: '#06121e',
  width: window.innerWidth,
  height: window.innerHeight,
  scene: [BootScene, HangarScene, CombatScene],
  scale: { mode: Phaser.Scale.RESIZE, autoCenter: Phaser.Scale.CENTER_BOTH },
  render: { antialias: true, pixelArt: false, roundPixels: false },
  input: { activePointers: 3 },
  banner: false
});

window.addEventListener('beforeunload', () => game.destroy(true));
