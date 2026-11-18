import Phaser from 'phaser';
import * as THREE from 'three';
import './style.css';
import './pwa';

type Controls = { x: number; z: number };

class TitanesScene extends Phaser.Scene {
  private world!: THREE.Scene;
  private camera3d!: THREE.PerspectiveCamera;
  private threeRenderer!: THREE.WebGLRenderer;
  private titan!: THREE.Group;
  private kaiju!: THREE.Group;
  private keys!: Record<string, Phaser.Input.Keyboard.Key>;
  private hp = 100;
  private energy = 100;
  private kaijuHp = 100;
  private score = 0;
  private attackCooldown = 0;
  private enemyCooldown = 0;
  private controls: Controls = { x: 0, z: 0 };
  private gameOver = false;
  private hpBar!: Phaser.GameObjects.Rectangle;
  private energyBar!: Phaser.GameObjects.Rectangle;
  private kaijuBar!: Phaser.GameObjects.Rectangle;
  private status!: Phaser.GameObjects.Text;
  private scoreText!: Phaser.GameObjects.Text;
  private overlay?: Phaser.GameObjects.Container;
  private readonly worldCanvas = document.createElement('canvas');

  constructor() { super('TitanesScene'); }

  create() {
    this.worldCanvas.id = 'world3d';
    document.querySelector('#game-root')?.prepend(this.worldCanvas);
    this.createWorld();
    this.keys = this.input.keyboard!.addKeys('W,A,S,D,UP,DOWN,LEFT,RIGHT,SPACE') as Record<string, Phaser.Input.Keyboard.Key>;
    this.createHud();
    this.scale.on('resize', this.resizeWorld, this);
    this.input.on('pointerup', () => { this.controls = { x: 0, z: 0 }; });
    this.input.on('pointerupoutside', () => { this.controls = { x: 0, z: 0 }; });
    this.events.once('shutdown', () => this.disposeWorld());
    this.events.once('destroy', () => this.disposeWorld());
  }

  private mat(color: number, metalness = 0.45) {
    return new THREE.MeshStandardMaterial({ color, metalness, roughness: 0.42 });
  }

  private block(parent: THREE.Group, size: [number, number, number], pos: [number, number, number], color: number) {
    const mesh = new THREE.Mesh(new THREE.BoxGeometry(...size), this.mat(color));
    mesh.position.set(...pos);
    mesh.castShadow = true;
    mesh.receiveShadow = true;
    parent.add(mesh);
    return mesh;
  }

  private buildJaeger(color: number) {
    const g = new THREE.Group();
    this.block(g, [1.8, 2.1, 1], [0, 2.8, 0], color);
    this.block(g, [1.05, 0.8, 0.9], [0, 4.25, 0], 0xc3d8df);
    this.block(g, [0.58, 0.16, 0.12], [0, 4.3, 0.48], 0x37e7ff);
    for (const x of [-1.2, 1.2]) {
      this.block(g, [0.72, 1.8, 0.8], [x, 2.9, 0], color);
      this.block(g, [0.68, 1.5, 0.72], [x * 0.72, 0.9, 0], 0x263f55);
      this.block(g, [0.65, 0.42, 0.7], [x * 0.72, 0.2, 0.05], 0x111e2c);
    }
    this.block(g, [0.5, 1.45, 0.6], [-0.28, 1.5, 0.08], 0x263f55);
    this.block(g, [0.5, 1.45, 0.6], [0.32, 1.5, 0.08], 0x263f55);
    return g;
  }

  private buildKaiju() {
    const g = new THREE.Group();
    this.block(g, [2.8, 2.5, 1.7], [0, 2.7, 0], 0x6b9b78);
    this.block(g, [1.7, 1.3, 1.4], [0, 4.35, 0.1], 0x47745f);
    this.block(g, [0.18, 0.18, 0.12], [-0.45, 4.45, 0.78], 0xff553e);
    this.block(g, [0.18, 0.18, 0.12], [0.45, 4.45, 0.78], 0xff553e);
    for (const x of [-1.7, 1.7]) {
      this.block(g, [0.75, 2.4, 0.8], [x, 2.8, 0], 0x47745f);
      this.block(g, [0.65, 1.8, 0.7], [x * 0.7, 0.9, 0], 0x355748);
    }
    return g;
  }

  private createWorld() {
    this.world = new THREE.Scene();
    this.world.background = new THREE.Color(0x071522);
    this.world.fog = new THREE.Fog(0x071522, 25, 80);
    this.camera3d = new THREE.PerspectiveCamera(55, innerWidth / innerHeight, 0.1, 160);
    this.camera3d.position.set(0, 8, 17);
    this.threeRenderer = new THREE.WebGLRenderer({ canvas: this.worldCanvas, antialias: true, alpha: false });
    this.threeRenderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 1.5));
    this.threeRenderer.setSize(innerWidth, innerHeight);
    this.threeRenderer.shadowMap.enabled = true;
    this.threeRenderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.world.add(new THREE.HemisphereLight(0xa9d9ff, 0x15212b, 2.1));
    const sun = new THREE.DirectionalLight(0xffffff, 2.3);
    sun.position.set(-8, 16, 8);
    sun.castShadow = true;
    this.world.add(sun);
    const floor = new THREE.Mesh(new THREE.PlaneGeometry(180, 180), this.mat(0x172b38, 0.15));
    floor.rotation.x = -Math.PI / 2;
    floor.position.y = -0.08;
    floor.receiveShadow = true;
    this.world.add(floor);
    const grid = new THREE.GridHelper(110, 55, 0x1b8095, 0x1b3d50);
    grid.position.y = 0.01;
    this.world.add(grid);
    for (let i = 0; i < 22; i++) {
      const h = 3 + Math.random() * 9;
      const building = new THREE.Mesh(new THREE.BoxGeometry(2 + Math.random() * 3, h, 2.5), this.mat(0x1b3343, 0.25));
      building.position.set((Math.random() - 0.5) * 62, h / 2, -14 - Math.random() * 42);
      this.world.add(building);
    }
    this.titan = this.buildJaeger(0x167c9c);
    this.titan.position.set(-3, 0, 3);
    this.world.add(this.titan);
    this.kaiju = this.buildKaiju();
    this.kaiju.position.set(4, 0, -8);
    this.world.add(this.kaiju);
    this.threeRenderer.render(this.world, this.camera3d);
  }

  private createHud() {
    this.add.text(22, 16, 'PACIFIC RIM  /  TITANES', { fontFamily: 'Arial', fontSize: '18px', color: '#8defff', fontStyle: 'bold' });
    this.add.text(22, 42, 'SECTOR: COSTA DEL PACÍFICO  •  ALERTA KAIJU', { fontSize: '10px', color: '#9bb7c5' });
    this.add.text(22, 64, 'INTEGRIDAD', { fontSize: '9px', color: '#b9d2dc' });
    this.add.rectangle(22, 82, 180, 9, 0x263b49).setOrigin(0, 0.5);
    this.hpBar = this.add.rectangle(22, 82, 180, 9, 0x37e7a4).setOrigin(0, 0.5);
    this.add.text(22, 94, 'ENERGÍA', { fontSize: '9px', color: '#b9d2dc' });
    this.add.rectangle(22, 112, 180, 7, 0x263b49).setOrigin(0, 0.5);
    this.energyBar = this.add.rectangle(22, 112, 180, 7, 0x39c8ff).setOrigin(0, 0.5);
    this.add.text(22, 126, 'RESISTENCIA KAIJU', { fontSize: '9px', color: '#b9d2dc' });
    this.add.rectangle(22, 144, 180, 7, 0x263b49).setOrigin(0, 0.5);
    this.kaijuBar = this.add.rectangle(22, 144, 180, 7, 0xff735e).setOrigin(0, 0.5);
    this.status = this.add.text(this.scale.width - 22, 22, 'OBJETIVO: NEUTRALIZAR AL KAIJU', { fontSize: '11px', color: '#ffb36b' }).setOrigin(1, 0);
    this.scoreText = this.add.text(this.scale.width - 22, 43, 'PUNTOS: 0', { fontSize: '11px', color: '#8defff' }).setOrigin(1, 0);
    this.add.text(22, this.scale.height - 22, 'WASD / FLECHAS: MOVER  •  ESPACIO: GOLPE  •  MÓVIL: CONTROLES EN PANTALLA', { fontSize: '9px', color: '#b4c7d2' }).setOrigin(0, 1);
    this.add.text(this.scale.width - 22, 66, 'PROTOTIPO JUGABLE', { fontSize: '9px', color: '#7896a5' }).setOrigin(1, 0);
    this.createTouchControls();
    this.scale.on('resize', (size: Phaser.Structs.Size) => {
      this.status.setPosition(size.width - 22, 22);
      this.scoreText.setPosition(size.width - 22, 43);
    });
  }

  private createTouchControls() {
    const makeButton = (x: number, y: number, label: string, down: () => void, up?: () => void, width = 48) => {
      const button = this.add.text(x, y, label, {
        fontSize: '16px', color: '#ffffff', backgroundColor: '#17465a',
        padding: { x: 12, y: 10 }, fontStyle: 'bold'
      }).setOrigin(0.5).setInteractive();
      button.setAlpha(0.88);
      button.on('pointerdown', (pointer: Phaser.Input.Pointer) => { pointer.event.stopPropagation(); down(); });
      if (up) button.on('pointerup', up);
      button.setFixedSize(width, 42);
      return button;
    };
    const y = this.scale.height - 88;
    const left = Math.max(42, this.scale.width - 228);
    makeButton(left, y, '◀', () => { this.controls.x = -1; }, () => { this.controls.x = 0; });
    makeButton(left + 54, y, '▶', () => { this.controls.x = 1; }, () => { this.controls.x = 0; });
    makeButton(left + 27, y - 49, '▲', () => { this.controls.z = -1; }, () => { this.controls.z = 0; });
    makeButton(left + 27, y + 49, '▼', () => { this.controls.z = 1; }, () => { this.controls.z = 0; });
    makeButton(this.scale.width - 75, y, 'GOLPE', () => this.attack(), undefined, 72);
  }

  private attack() {
    if (this.gameOver || this.attackCooldown > 0 || this.energy < 15) return;
    this.attackCooldown = 0.65;
    this.energy = Math.max(0, this.energy - 15);
    const distance = this.titan.position.distanceTo(this.kaiju.position);
    if (distance <= 11) {
      this.kaijuHp = Math.max(0, this.kaijuHp - 18);
      this.score += 100;
      this.status.setText('IMPACTO CONFIRMADO  +100');
      this.kaiju.position.x += this.kaiju.position.x > this.titan.position.x ? 0.65 : -0.65;
      if (this.kaijuHp === 0) this.finish(true);
    } else {
      this.status.setText('FUERA DE ALCANCE: ACÉRCATE AL KAIJU');
    }
  }

  private finish(won: boolean) {
    if (this.gameOver) return;
    this.gameOver = true;
    this.status.setText(won ? 'AMENAZA NEUTRALIZADA' : 'JAeger FUERA DE SERVICIO');
    const title = won ? 'SECTOR ASEGURADO' : 'MISIÓN INTERRUMPIDA';
    const subtitle = won ? 'El Kaiju ha sido derrotado. ¡Buen trabajo, piloto!' : 'Tu Jaeger necesita reparaciones. Inténtalo de nuevo.';
    const shade = this.add.rectangle(this.scale.width / 2, this.scale.height / 2, this.scale.width, this.scale.height, 0x020912, 0.82);
    const heading = this.add.text(this.scale.width / 2, this.scale.height / 2 - 42, title, { fontSize: '24px', color: '#8defff', fontStyle: 'bold' }).setOrigin(0.5);
    const detail = this.add.text(this.scale.width / 2, this.scale.height / 2, subtitle, { fontSize: '13px', color: '#d5e7ef', align: 'center', wordWrap: { width: Math.min(360, this.scale.width - 40) } }).setOrigin(0.5);
    const restart = this.add.text(this.scale.width / 2, this.scale.height / 2 + 58, 'VOLVER A JUGAR', { fontSize: '14px', color: '#ffffff', backgroundColor: '#12617a', padding: { x: 18, y: 12 } }).setOrigin(0.5).setInteractive();
    restart.on('pointerdown', () => this.scene.restart());
    this.overlay = this.add.container(0, 0, [shade, heading, detail, restart]).setDepth(20);
  }

  update(_time: number, delta: number) {
    if (!this.threeRenderer || this.gameOver) return;
    const dt = Math.min(delta / 1000, 0.04);
    this.attackCooldown = Math.max(0, this.attackCooldown - dt);
    this.enemyCooldown = Math.max(0, this.enemyCooldown - dt);
    const keyX = (this.keys.A.isDown || this.keys.LEFT.isDown ? -1 : 0) + (this.keys.D.isDown || this.keys.RIGHT.isDown ? 1 : 0);
    const keyZ = (this.keys.W.isDown || this.keys.UP.isDown ? -1 : 0) + (this.keys.S.isDown || this.keys.DOWN.isDown ? 1 : 0);
    const x = keyX || this.controls.x;
    const z = keyZ || this.controls.z;
    const length = Math.hypot(x, z) || 1;
    this.titan.position.x = Phaser.Math.Clamp(this.titan.position.x + (x / length) * dt * 5, -18, 18);
    this.titan.position.z = Phaser.Math.Clamp(this.titan.position.z + (z / length) * dt * 5, -18, 14);
    if (this.keys.SPACE.isDown) this.attack();
    this.energy = Math.min(100, this.energy + dt * 7);
    const distance = this.titan.position.distanceTo(this.kaiju.position);
    if (distance < 5.5 && this.enemyCooldown <= 0) {
      this.hp = Math.max(0, this.hp - 8);
      this.enemyCooldown = 1.1;
      this.status.setText('¡EL KAIJU CONTRAATACA!');
      if (this.hp === 0) this.finish(false);
    }
    this.hpBar.width = 180 * this.hp / 100;
    this.energyBar.width = 180 * this.energy / 100;
    this.kaijuBar.width = 180 * this.kaijuHp / 100;
    this.scoreText.setText('PUNTOS: ' + this.score);
    const targetCamera = new THREE.Vector3(this.titan.position.x, 7, this.titan.position.z + 13);
    this.camera3d.position.lerp(targetCamera, dt * 2);
    this.camera3d.lookAt(this.titan.position.x, 2, this.titan.position.z - 3);
    this.kaiju.rotation.y = Math.sin(_time * 0.0005) * 0.12;
    this.threeRenderer.render(this.world, this.camera3d);
  }

  private resizeWorld(size: Phaser.Structs.Size) {
    if (!this.camera3d || !this.threeRenderer) return;
    this.camera3d.aspect = size.width / Math.max(1, size.height);
    this.camera3d.updateProjectionMatrix();
    this.threeRenderer.setSize(size.width, size.height);
  }

  private disposeWorld() {
    if (!this.threeRenderer) return;
    this.world.traverse((object) => {
      const mesh = object as THREE.Mesh;
      if (mesh.geometry) mesh.geometry.dispose();
      if (mesh.material) {
        const materials = Array.isArray(mesh.material) ? mesh.material : [mesh.material];
        materials.forEach((material) => material.dispose());
      }
    });
    this.threeRenderer.dispose();
    this.worldCanvas.remove();
  }
}

new Phaser.Game({
  type: Phaser.CANVAS,
  parent: 'game-root',
  width: window.innerWidth,
  height: window.innerHeight,
  backgroundColor: '#071522',
  scene: [TitanesScene],
  scale: { mode: Phaser.Scale.RESIZE, autoCenter: Phaser.Scale.CENTER_BOTH },
  render: { antialias: true, pixelArt: false }
});
