import Phaser from 'phaser';
import * as THREE from 'three';
import './style.css';
import { TitanesSystems, JAEGERS } from './game-systems';
import { mountGamePanels } from './game-panels';
import './game-panels.css';

class TitanesScene extends Phaser.Scene {
  private world!: THREE.Scene;
  private camera3d!: THREE.PerspectiveCamera;
  private renderer!: THREE.WebGLRenderer;
  private titan!: THREE.Group;
  private kaiju!: THREE.Group;
  private keys!: Record<string, Phaser.Input.Keyboard.Key>;
  private hp = 100;
  private energy = 100;
  private score = 0;
  private kaijuHp = 100;
  private kaijuDefeated = false;
  private status!: Phaser.GameObjects.Text;
  private hpBar!: Phaser.GameObjects.Rectangle;
  private energyBar!: Phaser.GameObjects.Rectangle;
  private attackCooldown = 0;
  private moveX = 0;
  private moveZ = 0;
  private systems = new TitanesSystems();

  constructor() { super('TitanesScene'); }

  create() {
    const canvas = document.createElement('canvas');
    canvas.id = 'world3d';
    document.querySelector('#game-root')?.prepend(canvas);
    this.world = new THREE.Scene();
    this.world.background = new THREE.Color(0x071522);
    this.world.fog = new THREE.Fog(0x071522, 24, 75);
    this.camera3d = new THREE.PerspectiveCamera(55, innerWidth / innerHeight, 0.1, 150);
    this.camera3d.position.set(0, 7, 15);
    this.renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
    this.renderer.setPixelRatio(Math.min(devicePixelRatio, 1.7));
    this.renderer.setSize(innerWidth, innerHeight);
    this.renderer.shadowMap.enabled = true;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.buildWorld();
    this.keys = this.input.keyboard!.addKeys('W,A,S,D,UP,DOWN,LEFT,RIGHT,SPACE') as Record<string, Phaser.Input.Keyboard.Key>;
    this.buildHud();
    this.buildMainMenu();
    this.scale.on('resize', (size: Phaser.Structs.Size) => {
      this.camera3d.aspect = size.width / size.height;
      this.camera3d.updateProjectionMatrix();
      this.renderer.setSize(size.width, size.height);
    });
    this.events.once('destroy', () => { this.renderer.dispose(); canvas.remove(); });
    this.animate3d();
  }

  private buildMainMenu() {
    const menu=document.createElement('section'); menu.id='titan-menu';
    menu.innerHTML=`<header><b>PPDC // DEFENSE NETWORK</b><span>● ALERTA COSTERA</span><div class="menu-rank">PROTOCOLO DE DEFENSA · 2047</div></header><main><div class="menu-copy"><small>OPERACIÓN · PACÍFICO</small><h1>EL PACÍFICO<br><em>NO CAERÁ.</em></h1><p>La brecha sigue abierta. Despliega tu Jaeger, protege la costa y responde a la amenaza Kaiju.</p><div class="mission-card"><small>▰ MISIÓN ACTIVA · SECTOR 07</small><b>DEFENSA DE LA COSTA</b><span>OBJETIVO: interceptar al Kaiju y proteger la zona urbana.</span><div id="tm-resources" class="resource-strip"></div><div class="mission-progress"><i></i></div><label><span>AMENAZA DETECTADA</span><b>CLASE III</b></label></div><button id="tm-start">▶ DESPLEGAR JAEGER</button><button id="tm-hangar">▣ HANGAR / UNIDADES</button><button id="tm-upgrade">⬆ MEJORAR DEFENSA</button><small id="tm-system-notice"></small><footer><span>SECTOR<b>SHATTERDOME · COSTA</b></span><span>ESTADO<b>● SISTEMAS EN LÍNEA</b></span></footer></div><div class="tm-mech"><div class="rings"></div><div class="robot"><i class="head"><b></b></i><i class="body"><b></b></i><i class="arm a"></i><i class="arm b"></i><i class="leg c"></i><i class="leg d"></i></div><label>JAEGER // GIPSY-CLASS<small>UNIDAD DE COMBATE · MARK-III</small></label></div></main><div class="tm-bottom">PPDC · PAN-PACIFIC DEFENSE CORPS <span>INTERFAZ TÁCTICA v0.3</span></div><aside id="tm-roster"><div class="roster-window"><button id="tm-close">×</button><small>HANGAR / SELECCIÓN DE UNIDADES</small><h2>ESCUADRÓN JAEGER</h2><p>Selecciona una unidad para la misión. Las estadísticas son prototipos de juego.</p><div class="roster-cards"><article class="selected"><span class="unit-icon">01</span><b>GIPSY-CLASS</b><small>Equilibrado · Mark III</small><div class="unit-bars"><label>ARMADURA <i><b style="width:86%"></b></i></label><label>ENERGÍA <i><b style="width:74%"></b></i></label><label>AGILIDAD <i><b style="width:62%"></b></i></label></div></article><article><span class="unit-icon">02</span><b>STRIKER-CLASS</b><small>Rápido · Mark V</small><div class="unit-bars"><label>ARMADURA <i><b style="width:72%"></b></i></label><label>ENERGÍA <i><b style="width:91%"></b></i></label><label>AGILIDAD <i><b style="width:88%"></b></i></label></div></article><article><span class="unit-icon">03</span><b>CHERNO-CLASS</b><small>Pesado · Mark I</small><div class="unit-bars"><label>ARMADURA <i><b style="width:95%"></b></i></label><label>ENERGÍA <i><b style="width:68%"></b></i></label><label>AGILIDAD <i><b style="width:48%"></b></i></label></div></article></div><button id="tm-select">CONFIRMAR UNIDAD</button></div></aside>`;
    document.body.appendChild(menu);
    menu.querySelector('#tm-start')?.addEventListener('click',()=>{menu.classList.add('started'); mountGamePanels(this.systems); });
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
      const notice = menu.querySelector('#tm-system-notice');
      if (notice) notice.textContent = result.ok ? 'DEFENSA MEJORADA · NIVEL ' + result.level : 'RECURSOS INSUFICIENTES';
      renderResources();
    });
    menu.querySelectorAll('.roster-cards article').forEach((card, index) => card.addEventListener('click', () => {
      const ids = ['gipsy', 'striker', 'cherno'] as const;
      const id = ids[index]; if (!id) return;
      this.systems.setJaeger(id);
      menu.querySelectorAll('.roster-cards article').forEach(el => el.classList.remove('selected'));
      card.classList.add('selected');
      const heading = menu.querySelector('#tm-roster h2'); if (heading) heading.textContent = JAEGERS[id].label;
    }));
  }

  private material(color: number, metalness = 0.5) {
    return new THREE.MeshStandardMaterial({ color, metalness, roughness: 0.38 });
  }
  private box(parent: THREE.Group, size: [number,number,number], pos: [number,number,number], color: number) {
    const mesh = new THREE.Mesh(new THREE.BoxGeometry(...size), this.material(color));
    mesh.position.set(...pos); mesh.castShadow = true; mesh.receiveShadow = true; parent.add(mesh); return mesh;
  }
  private buildMech(color: number) {
    const g = new THREE.Group();
    this.box(g,[1.8,2.1,1],[0,2.8,0],color);
    this.box(g,[1.1,0.8,0.9],[0,4.25,0],0xc3d8df);
    this.box(g,[0.55,0.18,0.12],[0,4.3,0.48],0x37e7ff);
    for (const x of [-1.25,1.25]) {
      this.box(g,[0.75,1.9,0.8],[x,2.9,0],color);
      this.box(g,[0.7,1.6,0.75],[x*0.72,0.9,0],0x263f55);
      this.box(g,[0.65,0.45,0.7],[x*0.72,0.22,0.05],0x111e2c);
    }
    this.box(g,[0.55,1.5,0.65],[-0.25,1.5,0.1],0x263f55);
    this.box(g,[0.55,1.5,0.65],[0.35,1.5,0.1],0x263f55);
    return g;
  }
  private buildKaiju() {
    const g = new THREE.Group();
    this.box(g,[2.8,2.5,1.7],[0,2.7,0],0x6b9b78);
    this.box(g,[1.7,1.3,1.4],[0,4.35,0.1],0x47745f);
    this.box(g,[0.18,0.18,0.12],[-0.45,4.45,0.78],0xff553e);
    this.box(g,[0.18,0.18,0.12],[0.45,4.45,0.78],0xff553e);
    for (const x of [-1.7,1.7]) {
      this.box(g,[0.75,2.4,0.8],[x,2.8,0],0x47745f);
      this.box(g,[0.65,1.8,0.7],[x*0.7,0.9,0],0x355748);
    }
    return g;
  }
  private buildWorld() {
    this.world.add(new THREE.HemisphereLight(0x9ccfff,0x15212b,2.1));
    const sun = new THREE.DirectionalLight(0xffffff,2.5); sun.position.set(-8,15,8); sun.castShadow = true; this.world.add(sun);
    const floor = new THREE.Mesh(new THREE.PlaneGeometry(160,160),this.material(0x172b38,0.15));
    floor.rotation.x=-Math.PI/2; floor.position.y=-0.08; floor.receiveShadow=true; this.world.add(floor);
    const grid = new THREE.GridHelper(100,50,0x1b8095,0x1b3d50); grid.position.y=0.01; this.world.add(grid);
    for(let i=0;i<18;i++){
      const h=2+Math.random()*8, x=(Math.random()-.5)*55, z=-12-Math.random()*35;
      const b=new THREE.Mesh(new THREE.BoxGeometry(2+Math.random()*3,h,2),this.material(0x1b3343,0.25));
      b.position.set(x,h/2,z); this.world.add(b);
    }
    this.titan=this.buildMech(0x167c9c); this.titan.position.set(-3,0,3); this.world.add(this.titan);
    this.kaiju=this.buildKaiju(); this.kaiju.position.set(4,0,-8); this.world.add(this.kaiju);
  }
  private buildHud() {
    const w=this.scale.width;
    this.add.text(24,18,'PACIFIC RIM  /  TITANES',{fontFamily:'Arial',fontSize:'18px',color:'#8defff',fontStyle:'bold'}).setScrollFactor(0);
    this.add.text(24,45,'SECTOR: COSTA DEL PACÍFICO  •  ALERTA KAIJU',{fontSize:'10px',color:'#8ba8b8'}).setScrollFactor(0);
    this.add.rectangle(24,83,180,10,0x263b49).setOrigin(0,0.5);
    this.hpBar=this.add.rectangle(24,83,180,10,0x37e7a4).setOrigin(0,0.5);
    this.add.text(24,65,'INTEGRIDAD',{fontSize:'9px',color:'#b9d2dc'});
    this.add.rectangle(24,108,180,7,0x263b49).setOrigin(0,0.5);
    this.energyBar=this.add.rectangle(24,108,180,7,0x263b49).setOrigin(0,0.5);
    this.energyBar.setFillStyle(0x39c8ff);
    this.status=this.add.text(w-24,22,'OBJETIVO: NEUTRALIZAR AL KAIJU',{fontSize:'11px',color:'#ffb36b'}).setOrigin(1,0);
    this.add.text(24,this.scale.height-30,'WASD / FLECHAS: MOVER   •   ESPACIO: IMPACTO   •   MÓVIL: USA LOS CONTROLES',{fontSize:'10px',color:'#b4c7d2'}).setScrollFactor(0);
    const btn=(x:number,label:string,fn:()=>void)=>{const b=this.add.text(x,this.scale.height-95,label,{fontSize:'12px',color:'#ffffff',backgroundColor:'#12394b',padding:{x:13,y:12}}).setOrigin(.5).setInteractive();b.on('pointerdown',fn);return b;};
    btn(this.scale.width-190,'◀',()=>this.moveX=-1).on('pointerup',()=>this.moveX=0);
    btn(this.scale.width-135,'▶',()=>this.moveX=1).on('pointerup',()=>this.moveX=0);
    btn(this.scale.width-80,'IMPACTO',()=>this.attack());
    btn(this.scale.width-245,'▲',()=>this.moveZ=-1).on('pointerup',()=>this.moveZ=0);
    btn(this.scale.width-245,'▼',()=>this.moveZ=1);
  }
  private attack() {
    if(this.attackCooldown>0 || this.energy<12 || this.kaijuDefeated) return;
    this.attackCooldown=0.7; this.energy=Math.max(0,this.energy-12);
    const d=this.titan.position.distanceTo(this.kaiju.position);
    if(d<12){
      this.kaijuHp=Math.max(0,this.kaijuHp-20); this.kaiju.position.x+=this.kaiju.position.x>this.titan.position.x?1.3:-1.3; this.score+=100;
      if(this.kaijuHp<=0){
        this.kaijuDefeated=true; this.kaiju.visible=false;
        const result=this.systems.completeMission(1);
        this.status.setText(result.ok?'KAIJU DERROTADO · MISIÓN COMPLETADA · RECURSOS RECIBIDOS':'KAIJU DERROTADO · VICTORIA');
      } else this.status.setText('IMPACTO CONFIRMADO · KAIJU '+this.kaijuHp+'% · +100');
    } else this.status.setText('ACÉRCATE PARA ALCANZAR AL KAIJU');
  }
  update(_time:number,delta:number) {
    const dt=Math.min(delta/1000,0.04);
    this.attackCooldown=Math.max(0,this.attackCooldown-dt);
    const x=(this.keys.A.isDown||this.keys.LEFT.isDown?-1:0)+(this.keys.D.isDown||this.keys.RIGHT.isDown?1:0)+this.moveX;
    const z=(this.keys.W.isDown||this.keys.UP.isDown?-1:0)+(this.keys.S.isDown||this.keys.DOWN.isDown?1:0)+this.moveZ;
    this.titan.position.x+=x*dt*5; this.titan.position.z+=z*dt*5;
    if(this.keys.SPACE.isDown) this.attack();
    this.energy=Math.min(100,this.energy+dt*5);
    this.hpBar.width=180*this.hp/100; this.energyBar.width=180*this.energy/100;
    this.camera3d.position.lerp(new THREE.Vector3(this.titan.position.x,7,this.titan.position.z+12),dt*2);
    this.camera3d.lookAt(this.titan.position.x,2,this.titan.position.z-3);
    this.kaiju.rotation.y=Math.sin(_time*0.0005)*0.12;
    this.renderer.render(this.world,this.camera3d);
  }
  private animate3d() { this.game.events.on('step',()=>{}); }
}

new Phaser.Game({
  type: Phaser.CANVAS, parent:'game-root', width:innerWidth, height:innerHeight,
  backgroundColor:'#071522', scene:[TitanesScene],
  scale:{mode:Phaser.Scale.RESIZE,autoCenter:Phaser.Scale.CENTER_BOTH},
  render:{antialias:true,pixelArt:false}
});