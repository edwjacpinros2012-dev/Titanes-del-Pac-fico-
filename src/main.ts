import Phaser from 'phaser';
import * as THREE from 'three';
import './style.css';
import './menu-theme.css';
import { TitanesSystems, JAEGERS } from './game-systems';
import type { JaegerId } from './game-systems';
import { mountGamePanels } from './game-panels';
import './game-panels.css';
import { MissionDirector, type MissionBlueprint } from './mission-director';
import { getVisualProfile } from './visual-direction';

class TitanesScene extends Phaser.Scene {
  private world!: THREE.Scene;
  private camera3d!: THREE.PerspectiveCamera;
  private renderer3d!: THREE.WebGLRenderer;
  private titan!: THREE.Group;
  private kaiju!: THREE.Group;
  private activeJaegerId: JaegerId = 'gipsy';
  private jaegerArmorMaterial!: THREE.MeshStandardMaterial;
  private jaegerAccentMaterial!: THREE.MeshStandardMaterial;
  private mechRig!: { leftArm: THREE.Group; rightArm: THREE.Group; leftLeg: THREE.Group; rightLeg: THREE.Group; torso: THREE.Group };
  private kaijuRig!: { head: THREE.Group; tail: THREE.Group };
  private keys!: Record<string, Phaser.Input.Keyboard.Key>;
  private hp = 100;
  private energy = 100;
  private score = 0;
  private kaijuHp = 100;
  private kaijuDefeated = false;
  private buildingGroups: Record<string, THREE.Group> = {};
  private status!: Phaser.GameObjects.Text;
  private hpBar!: Phaser.GameObjects.Rectangle;
  private energyBar!: Phaser.GameObjects.Rectangle;
  private kaijuBar!: Phaser.GameObjects.Rectangle;
  private cityBar!: Phaser.GameObjects.Rectangle;
  private attackCooldown = 0;
  private kaijuAttackCooldown = 1.5;
  private battleStarted = false;
  private battleEnded = false;
  private startingIntegrity = 100;
  private cityDamageTaken = 0;
  private civilianGroup!: THREE.Group;
  private rescueUsed = false;
  private civiliansEvacuating = false;
  private civilianRescuePoint = new THREE.Vector3(11, 0, -14);
  private moveX = 0;
  private moveZ = 0;
  private attackPower = 20;
  private moveSpeed = 5;
  private systems = new TitanesSystems();
  private missionDirector = new MissionDirector(this.systems);
  private activeMission: MissionBlueprint | null = null;

  constructor() { super('TitanesScene'); }

  create() {
    const canvas = document.createElement('canvas');
    canvas.id = 'world3d';
    document.querySelector('#game-root')?.prepend(canvas);
    this.world = new THREE.Scene();
    const visualProfile = getVisualProfile(this.activeMission?.weather ?? 'LLUVIA COSTERA');
    this.world.background = new THREE.Color(visualProfile.skyColor);
    this.world.fog = new THREE.Fog(visualProfile.fogColor, visualProfile.fogNear, visualProfile.fogFar);
    this.camera3d = new THREE.PerspectiveCamera(55, innerWidth / innerHeight, 0.1, 150);
    this.camera3d.position.set(0, 7, 15);
    this.renderer3d = new THREE.WebGLRenderer({ canvas, antialias: true });
    this.renderer3d.setPixelRatio(Math.min(devicePixelRatio, 1.7));
    this.renderer3d.setSize(innerWidth, innerHeight);
    this.renderer3d.outputColorSpace = THREE.SRGBColorSpace;
    this.renderer3d.shadowMap.enabled = true;
    this.renderer3d.shadowMap.type = THREE.PCFSoftShadowMap;
    this.renderer3d.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer3d.toneMappingExposure = 1.08;
    this.activeMission = this.missionDirector.generate();
    this.buildWorld();
    this.applySelectedJaeger(this.systems.snapshot().selectedJaeger);
    this.animate3d();
    this.keys = this.input.keyboard!.addKeys('W,A,S,D,UP,DOWN,LEFT,RIGHT,SPACE,E') as Record<string, Phaser.Input.Keyboard.Key>;
    this.buildHud();
    this.buildMainMenu();
    this.scale.on('resize', (size: Phaser.Structs.Size) => {
      this.camera3d.aspect = size.width / size.height;
      this.camera3d.updateProjectionMatrix();
      this.renderer3d.setSize(size.width, size.height);
    });
    this.events.once('destroy', () => { this.renderer3d.setAnimationLoop(null); this.renderer3d.dispose(); canvas.remove(); });
  }

  private buildMainMenu() {
    const menu=document.createElement('section'); menu.id='titan-menu';
    menu.innerHTML=`<header><b>PPDC // DEFENSE NETWORK</b><span>● ALERTA COSTERA</span><div class="menu-rank">PROTOCOLO DE DEFENSA · 2047</div></header><main><div class="menu-copy"><small>OPERACIÓN · PACÍFICO</small><h1>EL PACÍFICO<br><em>NO CAERÁ.</em></h1><p>La brecha sigue abierta. Despliega tu Jaeger, protege la costa y responde a la amenaza Kaiju.</p><div class="mission-card"><small>▰ MISIÓN ACTIVA · SECTOR 07</small><b>DEFENSA DE LA COSTA</b><span>OBJETIVO: interceptar al Kaiju y proteger la zona urbana.</span><div id="tm-resources" class="resource-strip"></div><div class="mission-progress"><i></i></div><label><span>AMENAZA DETECTADA</span><b>CAT-III · RAZORFIN</b></label></div><button id="tm-start">▶ DESPLEGAR JAEGER</button><button id="tm-hangar">▣ HANGAR / UNIDADES</button><button id="tm-upgrade">⬆ MEJORAR DEFENSA</button><small id="tm-system-notice"></small><footer><span>SECTOR<b>SHATTERDOME · COSTA</b></span><span>ESTADO<b>● SISTEMAS EN LÍNEA</b></span></footer></div><div class="tm-mech"><div class="rings"></div><div class="robot"><i class="head"><b></b></i><i class="body"><b></b></i><i class="arm a"></i><i class="arm b"></i><i class="leg c"></i><i class="leg d"></i></div><label>JAEGER // GIPSY-CLASS<small>UNIDAD DE COMBATE · MARK-III</small></label></div></main><div class="tm-bottom">PPDC · PAN-PACIFIC DEFENSE CORPS <span>INTERFAZ TÁCTICA v0.3</span></div><aside id="tm-roster"><div class="roster-window"><button id="tm-close">×</button><small>HANGAR / SELECCIÓN DE UNIDADES</small><h2>ESCUADRÓN JAEGER</h2><p>Selecciona una unidad para la misión. Las estadísticas son prototipos de juego.</p><div class="roster-cards"><article class="${this.systems.snapshot().selectedJaeger === "gipsy" ? "selected" : ""}"><span class="unit-icon">01</span><b>GIPSY-CLASS</b><small>Equilibrado · Mark III</small><div class="unit-bars"><label>ARMADURA <i><b style="width:86%"></b></i></label><label>ENERGÍA <i><b style="width:74%"></b></i></label><label>AGILIDAD <i><b style="width:62%"></b></i></label></div></article><article class="${this.systems.snapshot().selectedJaeger === "striker" ? "selected" : this.systems.campaignProgress().completed >= 2 ? "" : "locked"}"><span class="unit-icon">02</span><b>STRIKER-CLASS</b><small>Rápido · Mark V</small><div class="unit-bars"><label>ARMADURA <i><b style="width:72%"></b></i></label><label>ENERGÍA <i><b style="width:91%"></b></i></label><label>AGILIDAD <i><b style="width:88%"></b></i></label></div></article><article class="${this.systems.snapshot().selectedJaeger === "cherno" ? "selected" : this.systems.campaignProgress().completed >= 4 ? "" : "locked"}"><span class="unit-icon">03</span><b>CHERNO-CLASS</b><small>Pesado · Mark I</small><div class="unit-bars"><label>ARMADURA <i><b style="width:95%"></b></i></label><label>ENERGÍA <i><b style="width:68%"></b></i></label><label>AGILIDAD <i><b style="width:48%"></b></i></label></div></article></div><button id="tm-select">CONFIRMAR UNIDAD</button></div></aside>`;
    document.body.appendChild(menu);
    menu.querySelector('#tm-start')?.addEventListener('click',()=>{this.activeMission=this.missionDirector.generate();this.kaijuHp=this.activeMission.kaijuIntegrity;this.kaijuAttackCooldown=this.activeMission.kaijuAttackInterval;this.battleStarted=true;menu.classList.add('started'); mountGamePanels(this.systems, (id) => {
      if (this.battleStarted && !this.battleEnded) {
        const stats = this.systems.getJaegerCombatStats();
        this.attackPower = Math.max(12, Math.round(stats.power / 4));
        this.moveSpeed = 3.2 + stats.agility / 30;
      } else this.applySelectedJaeger(id);
    }, (id) => this.refreshBuildingVisuals(id), () => !this.battleStarted || this.battleEnded); });
    menu.querySelector('#tm-hangar')?.addEventListener('click',()=>menu.querySelector('#tm-roster')?.classList.add('open'));
    menu.querySelector('#tm-close')?.addEventListener('click',()=>menu.querySelector('#tm-roster')?.classList.remove('open'));
    menu.querySelector('#tm-select')?.addEventListener('click',()=>menu.querySelector('#tm-roster')?.classList.remove('open'));
    const resources = menu.querySelector('#tm-resources');
    const renderResources = () => {
      const s = this.systems.snapshot();
      if (resources) resources.innerHTML = '<span>▰ ALEACIÓN <b>' + s.resources.alloy + '</b></span><span>◈ ENERGÍA <b>' + s.resources.energy + '</b></span><span>⌖ INTEL <b>' + s.resources.intel + '</b></span>';
    };
    renderResources();
    menu.querySelector('#tm-upgrade')?.addEventListener('click', () => {
      const result = this.systems.upgrade('defense');
      if (result.ok) this.applySelectedJaeger(this.systems.snapshot().selectedJaeger);
      const notice = menu.querySelector('#tm-system-notice');
      if (notice) notice.textContent = result.ok ? 'DEFENSA MEJORADA · NIVEL ' + result.level : 'RECURSOS INSUFICIENTES';
      renderResources();
    });
    menu.querySelectorAll('.roster-cards article').forEach((card, index) => card.addEventListener('click', () => {
      const ids = ['gipsy', 'striker', 'cherno'] as const;
      const id = ids[index]; if (!id || !this.systems.setJaeger(id)) return;
      this.applySelectedJaeger(id);
      menu.querySelectorAll('.roster-cards article').forEach(el => el.classList.remove('selected'));
      card.classList.add('selected');
      const heading = menu.querySelector('#tm-roster h2'); if (heading) heading.textContent = JAEGERS[id].label;
      const mechLabel = menu.querySelector('.tm-mech label'); if (mechLabel) mechLabel.innerHTML = 'JAEGER // ' + JAEGERS[id].label + '<small>UNIDAD DE COMBATE · PPDC</small>';
    }));
  }

  private applySelectedJaeger(id: JaegerId) {
    const combat = this.systems.getJaegerCombatStats();
    this.hp = this.systems.snapshot().jaegerIntegrity;
    this.startingIntegrity = this.hp;
    this.energy = 100;
    this.attackPower = Math.max(12, Math.round(combat.power / 4));
    this.moveSpeed = 3.2 + combat.agility / 30;
    const colors: Record<JaegerId, number> = { gipsy: 0x315d70, striker: 0xb38b36, cherno: 0x465b60 };
    const accents: Record<JaegerId, number> = { gipsy: 0xff9b42, striker: 0x68e8f2, cherno: 0xff654b };
    if (this.titan && this.world && this.activeJaegerId !== id) {
      const position = this.titan.position.clone();
      this.world.remove(this.titan);
      this.titan = this.buildMech(colors[id], id);
      this.titan.position.copy(position);
      this.world.add(this.titan);
      this.activeJaegerId = id;
    }
    if (this.jaegerArmorMaterial) this.jaegerArmorMaterial.color.setHex(colors[id]);
    if (this.jaegerAccentMaterial) {
      this.jaegerAccentMaterial.color.setHex(accents[id]);
      this.jaegerAccentMaterial.emissive.setHex(accents[id]);
    }
    if (this.titan) {
      const scale: Record<JaegerId, number> = { gipsy: 1, striker: 0.94, cherno: 1.12 };
      this.titan.scale.set(scale[id], scale[id], scale[id]);
    }
  }
  private material(color: number, metalness = 0.5) {
    return new THREE.MeshStandardMaterial({ color, metalness, roughness: 0.38 });
  }
  private box(parent: THREE.Group, size: [number,number,number], pos: [number,number,number], color: number) {
    const mesh = new THREE.Mesh(new THREE.BoxGeometry(...size), this.material(color));
    mesh.position.set(...pos); mesh.castShadow = true; mesh.receiveShadow = true; parent.add(mesh); return mesh;
  }
  private buildBase() {
    // Starter PPDC outpost: visible hangar, command block, generator, perimeter and evac area.
    const base = new THREE.Group(); base.position.set(-12,0,-2); this.world.add(base);
    this.box(base,[22,0.35,17],[0,0.1,0],0x253c4a);
    // Hangar shell and open front
    this.box(base,[12,4.8,0.7],[0,2.5,-4.8],0x1b3444);
    this.box(base,[0.8,4.5,9.2],[-5.8,2.3,0],0x24495c);
    this.box(base,[0.8,4.5,9.2],[5.8,2.3,0],0x24495c);
    this.box(base,[12,0.7,0.7],[0,4.9,-4.8],0x38758b);
    this.box(base,[12,0.45,0.7],[0,0.6,4.8],0x24485a);
    // Command center, reactor, storage and clinic blocks

    // Perimeter walls and gate
    this.box(base,[22,1.3,0.5],[0,0.8,8.0],0x263f50);
    this.box(base,[0.5,1.3,16],[-10.8,0.8,0],0x263f50);
    this.box(base,[0.5,1.3,16],[10.8,0.8,0],0x263f50);
    this.box(base,[5.8,1.3,0.5],[-7.8,0.8,-8.0],0x263f50);
    this.box(base,[5.8,1.3,0.5],[7.8,0.8,-8.0],0x263f50);
    // Watch towers with cyan lamps
    for(const x of [-10,10]){this.box(base,[1.2,4,1.2],[x,2,-7.5],0x203c4e);this.box(base,[1.8,0.3,1.8],[x,4.2,-7.5],0x4b7c8f);this.box(base,[0.3,0.2,0.3],[x,4.5,-7.5],0x51eaff);}
    // Evacuation tents and simple civilian silhouettes
    for(let i=0;i<(this.activeMission?.civilianCount ?? 6);i++){const x=-4.5+(i%3)*4.5,z=5.5+Math.floor(i/3)*1.4;this.box(base,[0.5,1.1,0.4],[x,1.1,z],i%2?0x497f8c:0x9a7651);const head=new THREE.Mesh(new THREE.SphereGeometry(0.22,8,8),this.material(0xc7a27a,0.1));head.position.set(x,1.85,z);base.add(head);}
    // Modular facilities are grouped so upgrades visibly change the 3D outpost.
    const facilities: Array<[string,[number,number,number],number]> = [
      ['command',[-8.0,0,-1.2],0x36586a],['hangar',[0,0,-4.6],0x1b3444],['reactor',[7.4,0,-3.0],0x287080],
      ['workshop',[7.4,0,1.2],0x345363],['medical',[-7.7,0,4.0],0x3a6577],
      ['defense',[0,0,7.0],0x45687a],['evacuation',[0,0,4.8],0x9a7651],['warehouse',[7.4,0,5.0],0x526b7a]
    ];
    for(const [id,pos,color] of facilities){
      const group=new THREE.Group(); group.position.set(...pos); base.add(group); this.buildingGroups[id]=group;
      const footprint=id==='command'?[4.6,3.5,3.8]:id==='hangar'?[11.2,3.6,4.6]:[3.2,2.5,3.0];
      this.box(group,[footprint[0],0.25,footprint[2]],[0,0.15,0],0x253b49);
      this.box(group,[footprint[0]*0.78,footprint[1],footprint[2]*0.72],[0,footprint[1]/2+0.2,0],color);
      this.box(group,[footprint[0]*0.9,0.28,footprint[0]*0.9],[0,footprint[1]+0.35,0],0x244b5c);
      for(const side of [-1,1]) this.box(group,[0.18,0.18,footprint[2]*0.55],[side*footprint[0]*0.42,footprint[1]*0.6,0],0x50d8ed);
      this.box(group,[0.22,0.35,0.22],[0,footprint[1]+0.6,0],0x52eaff);
      const labelCanvas=document.createElement('canvas'); labelCanvas.width=512; labelCanvas.height=128;
      const labelCtx=labelCanvas.getContext('2d');
      if(labelCtx){
        labelCtx.fillStyle='rgba(4,16,28,0.88)'; labelCtx.fillRect(0,0,512,128);
        labelCtx.strokeStyle='#45d8f0'; labelCtx.lineWidth=5; labelCtx.strokeRect(5,5,502,118);
        labelCtx.fillStyle='#d9f9ff'; labelCtx.font='bold 38px Arial'; labelCtx.textAlign='center';
        const labelText:Record<string,string>={command:'PPDC COMMAND',hangar:'JAEGER HANGAR',reactor:'ENERGY REACTOR',workshop:'MAINTENANCE',medical:'MEDICAL / EVAC',defense:'PERIMETER DEFENSE',evacuation:'CIVILIAN ZONE'};
        labelCtx.fillText(labelText[id]||id.toUpperCase(),256,78);
        const texture=new THREE.CanvasTexture(labelCanvas); texture.colorSpace=THREE.SRGBColorSpace;
        const sprite=new THREE.Sprite(new THREE.SpriteMaterial({map:texture,transparent:true}));
        sprite.position.set(0,footprint[1]+1.3,0); sprite.scale.set(4.6,1.15,1); group.add(sprite);
      }
    }
    this.refreshBuildingVisuals();
    // Marked rescue lane
    for(let i=0;i<5;i++)this.box(base,[0.3,0.04,2],[ -3+i*1.5,0.3,7.1],0x45d7ed);
  }
  private refreshBuildingVisuals(id?: string) {
    const levels=this.systems.snapshot().buildings;
    const keys=id?[id]:Object.keys(this.buildingGroups);
    for(const key of keys){
      const group=this.buildingGroups[key]; if(!group) continue;
      const level=levels[key]||0;
      const size=Math.max(0.62,0.72+level*0.16);
      group.scale.set(size,Math.max(0.65,0.72+level*0.22),size);
    }
  }
  private buildMech(color: number, id: JaegerId) {
    const root = new THREE.Group();
    const armor = new THREE.MeshStandardMaterial({ color, metalness: 0.82, roughness: 0.29 });
    const dark = new THREE.MeshStandardMaterial({ color: 0x172632, metalness: 0.88, roughness: 0.34 });
    const steel = new THREE.MeshStandardMaterial({ color: 0x657987, metalness: 0.9, roughness: 0.26 });
    const jaegerDesign: Record<JaegerId, { glow: number; emissive: number; shoulder: [number,number,number]; chest: [number,number,number]; crest: number }> = {
      gipsy: { glow: 0x39d8ed, emissive: 0x087eaa, shoulder: [1.08,0.82,1.02], chest: [1.9,1.65,1.05], crest: 1 },
      striker: { glow: 0xffa64b, emissive: 0xb94b16, shoulder: [0.68,0.82,0.7], chest: [1.55,1.48,0.88], crest: 2 },
      cherno: { glow: 0x75e2b2, emissive: 0x187b64, shoulder: [1.42,1.12,1.28], chest: [2.18,1.88,1.25], crest: 3 }
    };
    const design = jaegerDesign[id];
    const glow = new THREE.MeshStandardMaterial({ color: design.glow, emissive: design.emissive, emissiveIntensity: 2.0, metalness: 0.35, roughness: 0.22 });
    this.jaegerArmorMaterial = armor;
    this.jaegerAccentMaterial = glow;
    const add = (parent: THREE.Group, geometry: THREE.BufferGeometry, material: THREE.Material, pos: [number, number, number], rot: [number, number, number] = [0, 0, 0]) => {
      const mesh = new THREE.Mesh(geometry, material);
      mesh.position.set(...pos); mesh.rotation.set(...rot);
      mesh.castShadow = true; mesh.receiveShadow = true; parent.add(mesh); return mesh;
    };
    const panel = (parent: THREE.Group, size: [number, number, number], pos: [number, number, number], material: THREE.Material = armor, rot: [number, number, number] = [0, 0, 0]) =>
      add(parent, new THREE.BoxGeometry(...size), material, pos, rot);
    const joint = (parent: THREE.Group, pos: [number, number, number], radius = 0.32) =>
      add(parent, new THREE.SphereGeometry(radius, 14, 12), steel, pos);
    const cylinder = (parent: THREE.Group, radiusTop: number, radiusBottom: number, height: number, pos: [number, number, number], material: THREE.Material = dark, rot: [number, number, number] = [0, 0, 0]) =>
      add(parent, new THREE.CylinderGeometry(radiusTop, radiusBottom, height, 10), material, pos, rot);

    // Torso: layered chest, reactor housing, back pack and readable shoulder silhouette.
    const torso = new THREE.Group(); torso.position.y = 3.05; root.add(torso);
    panel(torso, design.chest, [0, 0, 0], armor);
    panel(torso, [1.45, 0.42, 0.16], [0, 0.52, 0.57], steel);
    panel(torso, [0.5, 0.9, 0.18], [0, -0.15, 0.61], dark);
    add(torso, new THREE.CylinderGeometry(0.32, 0.38, 0.18, 16), dark, [0, 0.12, 0.76], [Math.PI / 2, 0, 0]);
    add(torso, new THREE.CircleGeometry(0.25, 24), glow, [0, 0.12, 0.86], [0, 0, 0]);
    panel(torso, [0.55, 0.32, 0.2], [0, -0.73, 0.58], steel);
    panel(torso, [1.2, 1.0, 0.52], [0, 0.15, -0.66], dark);
    for (let i = 0; i < 4; i++) panel(torso, [0.12, 0.68, 0.12], [-0.43 + i * 0.29, 0.1, -0.94], steel);
    // Neck and compact armored head with a luminous horizontal visor.
    cylinder(torso, 0.28, 0.34, 0.38, [0, 0.98, 0], dark);
    const head = new THREE.Group(); head.position.set(0, 1.28, 0.06); torso.add(head);
    panel(head, [0.82, 0.65, 0.78], [0, 0, 0], steel);
    panel(head, [0.68, 0.22, 0.14], [0, -0.08, 0.42], glow);
    panel(head, [0.2, 0.32, 0.2], [-0.48, -0.02, 0.04], armor);
    panel(head, [0.2, 0.32, 0.2], [0.48, -0.02, 0.04], armor);
    // Shoulder pivots and articulated arms.
    const makeArm = (side: number) => {
      const arm = new THREE.Group(); arm.position.set(side * 1.22, 0.62, 0); torso.add(arm);
      joint(arm, [0, 0, 0], 0.42);
      panel(arm, design.shoulder, [side * 0.12, -0.35, 0], armor, [0, 0, side * -0.08]);
      panel(arm, [0.98, 0.28, 0.72], [side * 0.12, -0.03, 0.08], steel);
      cylinder(arm, 0.2, 0.24, 0.8, [0, -0.98, 0], dark);
      joint(arm, [0, -1.28, 0], 0.28);
      panel(arm, [0.72, 0.82, 0.72], [0, -1.7, 0.02], armor);
      panel(arm, [0.58, 0.2, 0.18], [0, -1.65, 0.39], glow);
      panel(arm, [0.54, 0.46, 0.52], [0, -2.28, 0.04], dark);
      for (let finger = 0; finger < 4; finger++) panel(arm, [0.1, 0.34, 0.12], [-0.2 + finger * 0.13, -2.62, 0.12], steel);
      return arm;
    };
    const leftArm = makeArm(-1), rightArm = makeArm(1);
    if (id === 'striker') {
      // Slim profile, swept shoulder fins and twin back thrusters.
      for (const side of [-1, 1]) {
        panel(torso, [0.28, 1.15, 0.62], [side * 1.0, 0.35, -0.35], steel, [0, 0, side * -0.32]);
        panel(torso, [0.12, 1.42, 0.42], [side * 1.08, 0.62, -0.42], armor, [0, 0, side * -0.48]);
        cylinder(torso, 0.24, 0.32, 0.8, [side * 0.48, 0.12, -0.92], glow);
        panel(torso, [0.18, 0.72, 0.25], [side * 0.9, -0.72, -0.7], dark);
      }
      panel(torso, [0.22, 0.82, 0.22], [0, 0.15, -1.08], glow);
    } else if (id === 'cherno') {
      // Heavy siege silhouette with reinforced shoulder and forearm plates.
      for (const side of [-1, 1]) {
        panel(torso, [1.15, 0.92, 1.15], [side * 1.18, 0.62, -0.02], armor);
        panel(torso, [0.9, 0.7, 0.96], [side * 1.36, -1.72, 0.08], steel);
        panel(torso, [0.3, 0.85, 0.32], [side * 0.72, 0.2, 0.7], glow);
      }
      panel(torso, [1.55, 0.35, 0.72], [0, -0.92, -0.72], steel);
      for (const side of [-1, 1]) {
        panel(torso, [0.22, 1.45, 0.9], [side * 1.82, 0.25, -0.08], dark, [0, 0, side * -0.12]);
        cylinder(torso, 0.3, 0.34, 0.9, [side * 0.72, 0.05, -0.98], glow);
      }
    } else {
      // Gipsy signature: compact shoulder armor and a framed circular reactor.
      for (const side of [-1, 1]) {
        panel(torso, [0.34, 0.82, 0.9], [side * 1.0, 0.55, 0.02], armor, [0, 0, side * -0.1]);
        panel(torso, [0.16, 0.42, 0.12], [side * 0.72, -0.2, 0.72], glow);
      }
    }
    // Hip block and two articulated legs with heavy feet.
    panel(root, [1.45, 0.62, 0.9], [0, 1.95, 0], dark);
    const makeLeg = (side: number) => {
      const leg = new THREE.Group(); leg.position.set(side * 0.62, 1.82, 0); root.add(leg);
      joint(leg, [0, 0, 0], 0.34);
      panel(leg, [0.78, 1.0, 0.86], [0, -0.55, 0], armor);
      panel(leg, [0.82, 0.25, 0.94], [0, -0.22, 0.12], steel);
      cylinder(leg, 0.23, 0.26, 0.72, [0, -1.2, 0], dark);
      joint(leg, [0, -1.52, 0.04], 0.28);
      panel(leg, [0.72, 0.88, 0.78], [0, -1.98, 0], armor);
      panel(leg, [0.84, 0.36, 1.18], [0, -2.48, 0.2], dark);
      panel(leg, [0.62, 0.12, 0.16], [0, -2.25, 0.61], glow);
      return leg;
    };
    const leftLeg = makeLeg(-1), rightLeg = makeLeg(1);
    // Hydraulic-looking side pistons, vents and small armor fins.
    for (const side of [-1, 1]) {
      cylinder(root, 0.09, 0.09, 1.15, [side * 1.48, 2.15, -0.18], steel, [0, 0, side * 0.18]);
      panel(root, [0.16, 0.9, 0.46], [side * 1.48, 3.95, -0.1], armor, [0, 0, side * -0.12]);
      panel(root, [0.12, 0.48, 0.12], [side * 0.92, 2.5, 0.55], glow);
    }
    this.mechRig = { leftArm, rightArm, leftLeg, rightLeg, torso };
    return root;
  }

  private buildKaiju() {
    const root = new THREE.Group();
    const category = this.activeMission?.category ?? 3;
    const kaijuVisuals: Record<number, { hide: number; armor: number; glow: number; body: [number, number, number]; crest: number }> = {
      1: { hide: 0x315e5a, armor: 0x183b3e, glow: 0x28d9e6, body: [0.9, 0.88, 1.0], crest: 5 },
      2: { hide: 0x405b50, armor: 0x243b34, glow: 0x82d8a1, body: [1.3, 1.08, 1.4], crest: 6 },
      3: { hide: 0x254e63, armor: 0x163347, glow: 0x4ddfff, body: [1.05, 0.92, 1.7], crest: 8 },
      4: { hide: 0x4b3d39, armor: 0x302a2a, glow: 0xff985e, body: [1.25, 1.35, 1.35], crest: 9 },
      5: { hide: 0x302d55, armor: 0x1a1c3b, glow: 0xb18cff, body: [1.55, 1.42, 1.65], crest: 11 }
    };
    const visual = kaijuVisuals[Math.max(1, Math.min(5, category))];
    const silhouette = [
      { body: [1.22,0.78,1.62] as [number,number,number], head: [1.0,0.68,1.18] as [number,number,number], limb: 0.82, tail: 1.28, dorsal: 5 },
      { body: [1.35,1.15,1.42] as [number,number,number], head: [1.0,0.82,1.0] as [number,number,number], limb: 1.0, tail: 1.05, dorsal: 7 },
      { body: [0.92,0.9,1.92] as [number,number,number], head: [0.86,0.68,1.52] as [number,number,number], limb: 0.9, tail: 1.65, dorsal: 9 },
      { body: [1.25,1.42,1.32] as [number,number,number], head: [1.08,0.94,1.22] as [number,number,number], limb: 1.18, tail: 1.15, dorsal: 10 },
      { body: [1.55,1.52,1.72] as [number,number,number], head: [1.28,1.02,1.42] as [number,number,number], limb: 1.32, tail: 1.45, dorsal: 12 }
    ][Math.max(0,Math.min(4,category-1))];
    const hide = new THREE.MeshStandardMaterial({ color: visual.hide, metalness: 0.28, roughness: 0.78 });
    const armor = new THREE.MeshStandardMaterial({ color: visual.armor, metalness: 0.5, roughness: 0.56 });
    const biolum = new THREE.MeshStandardMaterial({ color: visual.glow, emissive: visual.glow, emissiveIntensity: 1.35, roughness: 0.35 });
    const add = (parent: THREE.Group, geometry: THREE.BufferGeometry, material: THREE.Material, pos: [number, number, number], scale: [number, number, number] = [1, 1, 1], rot: [number, number, number] = [0, 0, 0]) => {
      const mesh = new THREE.Mesh(geometry, material); mesh.position.set(...pos); mesh.scale.set(...scale); mesh.rotation.set(...rot);
      mesh.castShadow = true; mesh.receiveShadow = true; parent.add(mesh); return mesh;
    };
    const body = add(root, new THREE.IcosahedronGeometry(1.5, 2), hide, [0, 2.55, 0], silhouette.body);
    body.rotation.x = -0.12;
    add(root, new THREE.IcosahedronGeometry(1, 1), armor, [0, category === 1 ? 3.28 : 3.55, -0.05], silhouette.head);
    // Rib plates and glowing bio-energy channels.
    for (let i = 0; i < 5; i++) {
      const z = 0.72 - i * 0.34;
      add(root, new THREE.BoxGeometry(0.13, 0.92 - i * 0.08, 0.12), biolum, [-0.84 + i * 0.02, 2.55, z], [1, 1, 1], [0, 0, -0.28]);
      add(root, new THREE.BoxGeometry(0.13, 0.92 - i * 0.08, 0.12), biolum, [0.84 - i * 0.02, 2.55, z], [1, 1, 1], [0, 0, 0.28]);
    }
    // Head, jaw, eyes and crown plates.
    const head = new THREE.Group(); head.position.set(0, 4.0, 0.72); root.add(head);
    add(head, new THREE.IcosahedronGeometry(0.78, 1), hide, [0, 0, 0], [1.0, 0.78, 1.22]);
    add(head, new THREE.BoxGeometry(1.05, 0.22, 0.92), armor, [0, -0.48, 0.28], [1, 1, 1], [0.18, 0, 0]);
    for (const side of [-1, 1]) {
      add(head, new THREE.SphereGeometry(0.11, 12, 10), biolum, [side * 0.38, 0.08, 0.88]);
      add(head, new THREE.ConeGeometry(0.22, 0.7, 6), armor, [side * 0.58, 0.55, -0.18], [1, 1, 1], [0, 0, side * -0.38]);
    }
    // Four heavy limbs with claws.
    for (const side of [-1, 1]) {
      const arm = new THREE.Group(); arm.position.set(side * 1.25, category === 1 ? 2.45 : 2.9, 0.15); arm.scale.setScalar(silhouette.limb); root.add(arm);
      add(arm, new THREE.IcosahedronGeometry(0.62, 1), hide, [side * 0.22, -0.42, 0], [0.8, 1.45, 0.8], [0, 0, side * -0.2]);
      add(arm, new THREE.IcosahedronGeometry(0.42, 1), armor, [side * 0.3, -1.38, 0.2], [0.9, 0.8, 0.9]);
      for (let claw = 0; claw < 3; claw++) add(arm, new THREE.ConeGeometry(0.11, 0.55, 6), armor, [side * 0.3 + (claw - 1) * 0.22, -1.85, 0.48], [1, 1, 1], [Math.PI / 2, 0, 0]);
    }
    for (const side of [-1, 1]) {
      const leg = new THREE.Group(); leg.position.set(side * 0.72, category === 1 ? 1.38 : 1.65, -0.1); leg.scale.setScalar(silhouette.limb); root.add(leg);
      add(leg, new THREE.IcosahedronGeometry(0.55, 1), hide, [0, -0.35, 0], [0.95, 1.25, 1.0]);
      add(leg, new THREE.IcosahedronGeometry(0.48, 1), armor, [0, -1.12, 0.18], [1.1, 0.72, 1.3]);
      add(leg, new THREE.ConeGeometry(0.12, 0.45, 6), armor, [0, -1.35, 0.62], [1, 1, 1], [Math.PI / 2, 0, 0]);
    }
    // Dorsal ridge and articulated tail.
    for (let i = 0; i < silhouette.dorsal; i++) add(root, new THREE.ConeGeometry(0.28 - i * 0.009, 0.72 - i * 0.022, 6), armor, [0, 3.35 + Math.sin(i * 0.35) * 0.12, -0.62 - i * 0.29], [1, 1, 1], [Math.PI / 2, 0, 0]);
    const tail = new THREE.Group(); tail.position.set(0, 2.1, -1.2); root.add(tail);
    for (let i = 0; i < 5; i++) {
      add(tail, new THREE.ConeGeometry((0.58 - i * 0.09) * silhouette.tail, 1.15 * silhouette.tail, 8), hide, [0, 0, -0.55 - i * 0.78], [1, 0.8, 1], [-Math.PI / 2, 0, 0]);
      add(tail, new THREE.ConeGeometry(0.16 - i * 0.02, 0.46, 6), armor, [0, 0.34, -0.55 - i * 0.78]);
    }
    this.kaijuRig = { head, tail };
    return root;
  }
  private buildCivilians() {
    this.civilianGroup = new THREE.Group();
    this.civilianGroup.position.set(11, 0, -14);
    this.civilianRescuePoint.set(11, 0, -14);
    for (let i = 0; i < 6; i++) {
      const civilian = new THREE.Group();
      const body = new THREE.Mesh(new THREE.BoxGeometry(0.48, 1.0, 0.36), this.material(i % 2 ? 0x4b8794 : 0xc08b52, 0.15));
      body.position.y = 0.72;
      const head = new THREE.Mesh(new THREE.SphereGeometry(0.22, 10, 8), this.material(0xc79d7a, 0.05));
      head.position.y = 1.38;
      civilian.add(body, head);
      civilian.position.set((i % 3 - 1) * 1.1, 0, Math.floor(i / 3) * 1.25);
      this.civilianGroup.add(civilian);
    }
    const saved = this.systems.snapshot();
    if (saved.rescuedMissions.includes(saved.unlockedMissions)) {
      this.civilianGroup.visible = false;
      this.rescueUsed = true;
    }
    this.world.add(this.civilianGroup);
  }

  private buildWorld() {
    const visual = getVisualProfile(this.activeMission?.weather ?? 'LLUVIA COSTERA');
    this.world.add(new THREE.HemisphereLight(visual.skyLight, visual.groundLight, visual.ambientIntensity));
    const sun = new THREE.DirectionalLight(visual.keyLight, visual.keyIntensity);
    sun.position.set(-8, 15, 8); sun.castShadow = true;
    sun.shadow.mapSize.set(1536, 1536);
    sun.shadow.camera.left = -42; sun.shadow.camera.right = 42;
    sun.shadow.camera.top = 42; sun.shadow.camera.bottom = -42;
    this.world.add(sun);
    const floorMaterial = new THREE.MeshStandardMaterial({
      color: visual.groundColor, metalness: 0.18, roughness: visual.groundRoughness
    });
    const floor = new THREE.Mesh(new THREE.PlaneGeometry(160, 100), floorMaterial);
    floor.rotation.x = -Math.PI / 2; floor.position.set(0, -0.08, 12); floor.receiveShadow = true; this.world.add(floor);
    // Coastal water plane: a real 3D surface, kept separate from the playable ground.
    const ocean = new THREE.Mesh(
      new THREE.PlaneGeometry(180, 72),
      new THREE.MeshStandardMaterial({
        color: visual.oceanColor, metalness: 0.48, roughness: 0.24,
        emissive: visual.oceanGlow, emissiveIntensity: 0.16
      })
    );
    ocean.rotation.x = -Math.PI / 2; ocean.position.set(0, -0.12, -72);
    ocean.receiveShadow = true; this.world.add(ocean);
    // Industrial coastal causeway and wet reflective lane markings.
    const causeway = new THREE.Mesh(
      new THREE.BoxGeometry(42, 0.12, 8),
      new THREE.MeshStandardMaterial({ color: 0x263b46, metalness: 0.28, roughness: 0.42 })
    );
    causeway.position.set(0, -0.01, -28); causeway.receiveShadow = true; this.world.add(causeway);
    for (let i = -5; i <= 5; i++) {
      const marker = new THREE.Mesh(
        new THREE.BoxGeometry(1.5, 0.025, 0.12),
        new THREE.MeshStandardMaterial({ color: 0x8a9b91, emissive: 0x1d3538, emissiveIntensity: 0.18 })
      );
      marker.position.set(i * 3.5, 0.07, -28); this.world.add(marker);
    }
    this.buildBase();
    this.buildCivilians();
    let levelSeed = this.activeMission?.seed ?? 1;
    const levelRandom = () => {
      levelSeed = (levelSeed * 1664525 + 1013904223) >>> 0;
      return levelSeed / 4294967296;
    };
    const missionBuildings = new THREE.Group();
    for(let i=0;i<24;i++){
      const h=3+levelRandom()*12;
      const side = i % 2 === 0 ? -1 : 1;
      const x=side*(13+levelRandom()*15);
      const z=-25+levelRandom()*43;
      const width=2.4+levelRandom()*3.6;
      const building=new THREE.Mesh(new THREE.BoxGeometry(width,h,2.5+levelRandom()*3),this.material(i%4===0?0x294454:0x1b3343,0.32));
      building.position.set(x,h/2,z);
      building.castShadow=true;
      building.receiveShadow=true;
      missionBuildings.add(building);
      const beacon=new THREE.Mesh(new THREE.BoxGeometry(width*0.72,0.08,0.06),new THREE.MeshStandardMaterial({color:0x58cde2,emissive:0x1c8ca8,emissiveIntensity:0.65,roughness:0.35}));
      beacon.position.set(x,h*0.72,z+1.55);
      missionBuildings.add(beacon);
    }
    for(let i=0;i<8;i++){
      const crate=new THREE.Mesh(new THREE.BoxGeometry(1.8,1.2,1.8),this.material(0x735b3c,0.75));
      crate.position.set((levelRandom()-.5)*18,0.6, -12+levelRandom()*26);
      missionBuildings.add(crate);
    }
    this.world.add(missionBuildings);
    this.activeJaegerId = this.systems.snapshot().selectedJaeger;
    const jaegerColors: Record<JaegerId, number> = { gipsy: 0x315d70, striker: 0xb38b36, cherno: 0x465b60 };
    this.titan=this.buildMech(jaegerColors[this.activeJaegerId], this.activeJaegerId); this.titan.position.set(-3,0,3); this.world.add(this.titan);
    this.kaiju=this.buildKaiju(); this.kaiju.position.set(4,0,-8); this.world.add(this.kaiju);
  }
  private buildHud() {
    const w=this.scale.width;
    this.add.text(24,18,'PACIFIC RIM  /  TITANES',{fontFamily:'Arial',fontSize:'18px',color:'#8defff',fontStyle:'bold'}).setScrollFactor(0);
    this.add.text(24,45,`${this.activeMission?.district ?? this.activeMission?.sector ?? 'SECTOR: COSTA DEL PACÍFICO'} · ${this.activeMission?.weather ?? 'ALERTA KAIJU'}`,{fontSize:'10px',color:'#8ba8b8'}).setScrollFactor(0);
    this.add.rectangle(24,83,180,10,0x263b49).setOrigin(0,0.5);
    this.hpBar=this.add.rectangle(24,83,180,10,0x37e7a4).setOrigin(0,0.5);
    this.add.text(24,65,'INTEGRIDAD',{fontSize:'9px',color:'#b9d2dc'});
    this.add.rectangle(24,108,180,7,0x263b49).setOrigin(0,0.5);
    this.energyBar=this.add.rectangle(24,108,180,7,0x263b49).setOrigin(0,0.5);
    this.energyBar.setFillStyle(0x39c8ff);
    this.add.text(24,125,'KAIJU / INTEGRIDAD',{fontSize:'9px',color:'#b9d2dc'}).setScrollFactor(0);
    this.add.rectangle(24,143,180,7,0x263b49).setOrigin(0,0.5);
    this.kaijuBar=this.add.rectangle(24,143,180,7,0xff654b).setOrigin(0,0.5);
    this.add.text(24,158,'CIUDAD / INTEGRIDAD',{fontSize:'9px',color:'#b9d2dc'}).setScrollFactor(0);
    this.add.rectangle(24,176,180,7,0x263b49).setOrigin(0,0.5);
    this.cityBar=this.add.rectangle(24,176,180*this.systems.snapshot().cityIntegrity/100,7,0xffb36d).setOrigin(0,0.5);
    this.status=this.add.text(w-24,22,`OBJETIVO: ${this.activeMission?.objective ?? 'NEUTRALIZAR AL KAIJU'}`,{fontSize:'11px',color:'#ffb36b',wordWrap:{width:Math.min(360,w*0.42)}}).setOrigin(1,0);
    this.add.text(24,this.scale.height-30,'WASD / FLECHAS: MOVER   •   ESPACIO: IMPACTO   •   E: RESCATAR CIVILES   •   MÓVIL: USA LOS CONTROLES',{fontSize:'10px',color:'#b4c7d2'}).setScrollFactor(0);
    const btn=(x:number,y:number,label:string,fn:()=>void)=>{const b=this.add.text(x,y,label,{fontSize:'12px',color:'#ffffff',backgroundColor:'#12394b',padding:{x:13,y:12}}).setOrigin(.5).setInteractive();b.on('pointerdown',fn);return b;};
    const controlX=this.scale.width-142, controlY=this.scale.height-110, gap=48;
    btn(controlX,controlY-gap,'▲',()=>this.moveZ=-1).on('pointerup',()=>this.moveZ=0).on('pointerout',()=>this.moveZ=0);
    btn(controlX-gap,controlY,'◀',()=>this.moveX=-1).on('pointerup',()=>this.moveX=0).on('pointerout',()=>this.moveX=0);
    btn(controlX+gap,controlY,'▶',()=>this.moveX=1).on('pointerup',()=>this.moveX=0).on('pointerout',()=>this.moveX=0);
    btn(controlX,controlY+gap,'▼',()=>this.moveZ=1).on('pointerup',()=>this.moveZ=0).on('pointerout',()=>this.moveZ=0);
    btn(this.scale.width-58,this.scale.height-110,'IMPACTO',()=>this.attack());
    btn(this.scale.width-86,76,'RETIRADA',()=>this.finishMission('retreat'));
  }
  private finishMission(outcome: 'victory' | 'defeat' | 'retreat') {
    if (!this.battleStarted || this.battleEnded) return;
    this.battleEnded = true;
    const missionId = this.systems.snapshot().unlockedMissions;
    const damageTaken = Math.max(0, this.startingIntegrity - this.hp);
    const cityDamage = Math.min(100, this.cityDamageTaken + (outcome === 'defeat' ? 18 : outcome === 'retreat' ? 6 : 0));
    const result = this.systems.resolveMission(missionId, outcome, damageTaken, cityDamage);
    if (!result.ok) {
      this.status.setText('RESULTADO NO GUARDADO · ' + (result.reason || 'Comprueba el almacenamiento'));
      return;
    }
    if (outcome === 'victory') {
      this.status.setText('VICTORIA · +' + result.reward.alloy + ' ALEACIÓN · +' + result.reward.energy + ' ENERGÍA · +' + result.reward.intel + ' DATOS · +' + result.reward.xp + ' XP · JAEGER ' + result.jaegerIntegrity + '%');
    } else if (outcome === 'defeat') {
      this.status.setText('DERROTA · JAEGER ' + result.jaegerIntegrity + '% · CIUDAD ' + result.cityIntegrity + '% · REPARACIÓN REQUERIDA');
    } else {
      this.status.setText('RETIRADA · JAEGER ' + result.jaegerIntegrity + '% · CIUDAD ' + result.cityIntegrity + '% · MISIÓN PENDIENTE');
    }
  }

  private attack() {
    if(!this.battleStarted || this.battleEnded || this.attackCooldown>0 || this.energy<12 || this.kaijuDefeated) return;
    this.attackCooldown=0.7; this.energy=Math.max(0,this.energy-12);
    const d=this.titan.position.distanceTo(this.kaiju.position);
    if(d<12){
      this.kaijuHp=Math.max(0,this.kaijuHp-this.attackPower); this.kaiju.position.x+=this.kaiju.position.x>this.titan.position.x?1.3:-1.3; this.score+=100;
      if(this.kaijuHp<=0){
        this.kaijuDefeated=true; this.kaiju.visible=false;
        this.finishMission('victory');
      } else this.status.setText('IMPACTO CONFIRMADO · KAIJU '+this.kaijuHp+'% · +100');
    } else this.status.setText('ACÉRCATE PARA ALCANZAR AL KAIJU');
  }
  update(_time:number,delta:number) {
    const dt=Math.min(delta/1000,0.04);
    if (!this.battleStarted || this.battleEnded) return;
    this.attackCooldown=Math.max(0,this.attackCooldown-dt);
    this.kaijuAttackCooldown=Math.max(0,this.kaijuAttackCooldown-dt);
    const x=(this.keys.A.isDown||this.keys.LEFT.isDown?-1:0)+(this.keys.D.isDown||this.keys.RIGHT.isDown?1:0)+this.moveX;
    const z=(this.keys.W.isDown||this.keys.UP.isDown?-1:0)+(this.keys.S.isDown||this.keys.DOWN.isDown?1:0)+this.moveZ;
    this.titan.position.x+=x*dt*this.moveSpeed; this.titan.position.z+=z*dt*this.moveSpeed;
    if (this.civilianGroup.visible) {
      this.civilianGroup.children.forEach((npc, index) => {
        npc.rotation.y = Math.sin(_time * 0.0008 + index * 1.7) * 0.07;
        if (this.civiliansEvacuating) {
          const target = new THREE.Vector3(-3.2 + (index % 3) * 0.65, 0, 6.2 + Math.floor(index / 3) * 0.75);
          npc.position.lerp(target, Math.min(1, dt * 0.45));
        } else {
          npc.position.y = Math.abs(Math.sin(_time * 0.0014 + index)) * 0.035;
        }
      });
    }
    if (!this.battleEnded && !this.rescueUsed && this.civilianGroup.visible && this.titan.position.distanceTo(this.civilianRescuePoint) < 6) {
      this.status.setText('ZONA DE EVACUACIÓN · PRESIONA E PARA RESCATAR 6 CIVILES');
      if (Phaser.Input.Keyboard.JustDown(this.keys.E)) {
        const missionId = this.systems.snapshot().unlockedMissions;
        const civilianCount = this.activeMission?.civilianCount ?? 6;
        const result = this.systems.rescueCivilians(civilianCount, missionId);
        if (result.ok) {
          this.rescueUsed = true;
          this.civilianGroup.visible = false;
          this.status.setText(`EVACUACIÓN COMPLETADA · ${civilianCount} CIVILES A SALVO · +${civilianCount*8} ALEACIÓN · +${civilianCount*4} ENERGÍA · +${civilianCount*5} XP`);
        } else this.status.setText(result.reason || 'NO SE PUDO REGISTRAR LA EVACUACIÓN');
      }
    }
    if (!this.battleEnded) {
      const jaegerDistance = this.titan.position.distanceTo(this.kaiju.position);
      const kaijuTarget = jaegerDistance < 22 ? this.titan.position : new THREE.Vector3(0, 0, 9);
      const pursuit = kaijuTarget.clone().sub(this.kaiju.position);
      if (pursuit.length() > 8) this.kaiju.position.addScaledVector(pursuit.normalize(), dt * (1.15 + (this.activeMission?.category ?? 1) * 0.12));
    }
    if (!this.battleEnded && this.kaijuAttackCooldown <= 0) {
      this.kaijuAttackCooldown = this.activeMission?.kaijuAttackInterval ?? 2.2;
      if (this.titan.position.distanceTo(this.kaiju.position) < 16) {
        const armor = this.systems.getJaegerCombatStats().armor;
        const damage = Math.max(5, Math.round((this.activeMission?.kaijuDamage ?? 15) - Math.floor(armor / 12)));
        this.hp = Math.max(0, this.hp - damage);
        this.status.setText('IMPACTO KAIJU · -' + damage + ' INTEGRIDAD');
        if (this.hp <= 0) this.finishMission('defeat');
      } else {
        this.cityDamageTaken = Math.min(100, this.cityDamageTaken + (this.activeMission?.cityPressure ?? 8));
        this.civiliansEvacuating = true;
        this.civilianRescuePoint.set(8, 0, -8);
        const remainingCityIntegrity = Math.max(0, this.systems.snapshot().cityIntegrity - this.cityDamageTaken);
        this.status.setText((this.activeMission?.kaijuName ?? 'KAIJU') + ' PRESIONA LA CIUDAD · INTEGRIDAD ' + remainingCityIntegrity + '%');
        if (remainingCityIntegrity <= 0) this.finishMission('defeat');
      }
    }
    if(!this.battleEnded && this.keys.SPACE.isDown) this.attack();
    this.energy=Math.min(100,this.energy+dt*5);
    this.hpBar.width=180*this.hp/100; this.energyBar.width=180*this.energy/100; this.kaijuBar.width=180*this.kaijuHp/100; this.cityBar.width=180*Math.max(0,this.systems.snapshot().cityIntegrity-this.cityDamageTaken)/100;
    this.camera3d.position.lerp(new THREE.Vector3(this.titan.position.x,7,this.titan.position.z+12),dt*2);
    this.camera3d.lookAt(this.titan.position.x,2,this.titan.position.z-3);
    this.kaiju.rotation.y=Math.sin(_time*0.0005)*0.12;
    if (this.mechRig) {
      const stride = Math.sin(_time * 0.004) * (Math.abs(x) + Math.abs(z) > 0 ? 0.18 : 0.025);
      this.mechRig.leftLeg.rotation.x = stride;
      this.mechRig.rightLeg.rotation.x = -stride;
      this.mechRig.leftArm.rotation.x = -stride * 0.65;
      this.mechRig.rightArm.rotation.x = stride * 0.65;
      this.mechRig.torso.rotation.z = Math.sin(_time * 0.0018) * 0.012;
    }
    if (this.kaijuRig) {
      this.kaijuRig.head.rotation.x = Math.sin(_time * 0.0011) * 0.035;
      this.kaijuRig.tail.rotation.y = Math.sin(_time * 0.0014) * 0.18;
      this.kaijuRig.tail.rotation.x = Math.cos(_time * 0.001) * 0.035;
    }
  }
  private animate3d() { this.renderer3d.setAnimationLoop(() => { if (this.world && this.camera3d) this.renderer3d.render(this.world, this.camera3d); }); }
}

new Phaser.Game({
  type: Phaser.CANVAS, parent:'game-root', width:innerWidth, height:innerHeight,
  backgroundColor:'#071522', scene:[TitanesScene],
  scale:{mode:Phaser.Scale.RESIZE,autoCenter:Phaser.Scale.CENTER_BOTH},
  render:{antialias:true,pixelArt:false}
});