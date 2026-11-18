import Phaser from 'phaser';
import { GAME } from '../config/game';
export class HangarScene extends Phaser.Scene {
  constructor(){ super('HangarScene'); }
  create(){
    const w=this.scale.width, h=this.scale.height;
    this.cameras.main.setBackgroundColor(GAME.colors.background);
    this.add.rectangle(w/2,h/2,w,h,0x06121e);
    for(let i=0;i<36;i++){const x=(i*173)%w,y=(i*97)%h;this.add.circle(x,y,i%3===0?2:1,0x3d8298,.45);}
    this.add.text(42,34,'SHATTERDOME  /  SISTEMA DE DEFENSA',{fontFamily:'Arial',fontSize:'12px',color:'#64dff2',letterSpacing:3});
    this.add.text(w/2,h*.29,'PACIFIC RIM',{fontFamily:'Arial Black, Arial',fontSize:Math.min(64,w*.095),fontStyle:'bold',color:'#e9f8ff',stroke:'#087e9b',strokeThickness:2}).setOrigin(.5);
    this.add.text(w/2,h*.29+66,'T I T A N E S',{fontSize:'20px',color:'#56dff5',letterSpacing:9}).setOrigin(.5);
    this.add.rectangle(w/2,h*.58,Math.min(500,w-48),1,0x2a8095,.8);
    this.add.text(w/2,h*.64,'PROTOTIPO VISUAL 3D  •  SECTOR PACÍFICO',{fontSize:'12px',color:'#90aebd',letterSpacing:2}).setOrigin(.5);
    const button=this.add.text(w/2,h*.77,'  INICIAR SIMULACIÓN  ',{fontSize:'16px',fontStyle:'bold',color:'#06121e',backgroundColor:'#59e8f6',padding:{x:22,y:16}}).setOrigin(.5).setInteractive({useHandCursor:true});
    button.on('pointerover',()=>button.setStyle({backgroundColor:'#b2f7ff'}));
    button.on('pointerout',()=>button.setStyle({backgroundColor:'#59e8f6'}));
    button.on('pointerdown',()=>this.scene.start('CombatScene'));
    this.add.text(w/2,h-34,'PHASER 3  +  THREE.JS  |  BUILD PROVISIONAL',{fontSize:'10px',color:'#547789',letterSpacing:2}).setOrigin(.5);
    this.scale.on('resize',(s:Phaser.Structs.Size)=>{this.scene.restart();});
  }
}
