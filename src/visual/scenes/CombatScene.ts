import Phaser from 'phaser';
import { World3D } from '../world/World3D';
import { GAME } from '../config/game';
export class CombatScene extends Phaser.Scene {
 private world!:World3D;private keys!:Record<string,Phaser.Input.Keyboard.Key>;private hp=100;private energy=100;private enemy=100;private cooldown=0;private move={x:0,z:0};private hpBar!:Phaser.GameObjects.Rectangle;private energyBar!:Phaser.GameObjects.Rectangle;private enemyBar!:Phaser.GameObjects.Rectangle;private message!:Phaser.GameObjects.Text;private lastTime=0;
 constructor(){super('CombatScene');}
 create(){
  const canvas=document.createElement('canvas');canvas.id='world3d';canvas.style.cssText='position:absolute;inset:0;width:100%;height:100%;display:block';this.game.canvas.parentElement?.prepend(canvas);
  const host=this.game.canvas.parentElement as HTMLElement;this.world=new World3D(canvas,host);
  this.keys=this.input.keyboard!.addKeys('W,A,S,D,UP,DOWN,LEFT,RIGHT,SPACE') as Record<string,Phaser.Input.Keyboard.Key>;
  this.createHud();this.events.once('shutdown',()=>{this.world.destroy();canvas.remove();});
 }
 private createHud(){
  this.add.text(24,18,GAME.title,{fontSize:'17px',fontStyle:'bold',color:'#8defff'}).setDepth(10);
  this.add.text(24,43,'SECTOR COSTA DEL PACÍFICO  /  ALERTA KAIJU',{fontSize:'10px',color:'#91afbd'}).setDepth(10);
  const bar=(y:number,label:string,color:number)=>{this.add.text(24,y-15,label,{fontSize:'9px',color:'#bdd5df'}).setDepth(10);this.add.rectangle(24,y,190,9,0x233d4b).setOrigin(0,.5).setDepth(10);return this.add.rectangle(24,y,190,9,color).setOrigin(0,.5).setDepth(11);};
  this.hpBar=bar(83,'INTEGRIDAD',0x43e5a3);this.energyBar=bar(119,'ENERGÍA',0x45cfff);this.enemyBar=bar(155,'KAIJU',0xff685e);
  this.message=this.add.text(this.scale.width-24,24,'OBJETIVO: NEUTRALIZAR AL KAIJU',{fontSize:'11px',color:'#ffc17b'}).setOrigin(1,0).setDepth(10);
  this.add.text(24,this.scale.height-28,'WASD / FLECHAS: MOVER  •  ESPACIO: IMPACTO',{fontSize:'10px',color:'#c1d3dc'}).setDepth(10);
  this.makeTouchControls();
 }
 private makeTouchControls(){
  const button=(x:number,y:number,label:string,down:()=>void,up:()=>void)=>{const b=this.add.text(x,y,label,{fontSize:'17px',color:'#fff',backgroundColor:'#123b50',padding:{x:15,y:12}}).setOrigin(.5).setDepth(20).setInteractive();b.on('pointerdown',down);b.on('pointerup',up);b.on('pointerout',up);return b;};
  const y=this.scale.height-85,x=this.scale.width-190;
  button(x-58,y,'◀',()=>this.move.x=-1,()=>this.move.x=0);button(x+58,y,'▶',()=>this.move.x=1,()=>this.move.x=0);
  button(x,y-48,'▲',()=>this.move.z=-1,()=>this.move.z=0);button(x,y+48,'▼',()=>this.move.z=1,()=>this.move.z=0);
  button(this.scale.width-70,y,'IMPACTO',()=>this.attack(),()=>{});
 }
 private attack(){if(this.cooldown>0||this.energy<GAME.combat.attackCost||this.enemy<=0)return;this.cooldown=GAME.combat.attackCooldown;this.energy-=GAME.combat.attackCost;const distance=this.world.titan.position.distanceTo(this.world.kaiju.position);if(distance<=GAME.combat.attackRange){this.enemy=Math.max(0,this.enemy-GAME.combat.attackDamage);this.message.setText(this.enemy===0?'VICTORIA  /  SECTOR ASEGURADO':'IMPACTO CONFIRMADO');}else this.message.setText('ACÉRCATE PARA ALCANZAR AL KAIJU');}
 update(time:number,delta:number){
  const dt=Math.min(delta/1000,.04);this.cooldown=Math.max(0,this.cooldown-delta);const x=(this.keys.A.isDown||this.keys.LEFT.isDown?-1:0)+(this.keys.D.isDown||this.keys.RIGHT.isDown?1:0)+this.move.x;const z=(this.keys.W.isDown||this.keys.UP.isDown?-1:0)+(this.keys.S.isDown||this.keys.DOWN.isDown?1:0)+this.move.z;
  this.world.titan.position.x+=x*GAME.combat.moveSpeed*dt;this.world.titan.position.z+=z*GAME.combat.moveSpeed*dt;if(this.keys.SPACE.isDown)this.attack();this.energy=Math.min(100,this.energy+dt*7);
  this.hpBar.width=190*this.hp/100;this.energyBar.width=190*this.energy/100;this.enemyBar.width=190*this.enemy/100;this.world.render(time);this.lastTime=time;
 }
 shutdown(){this.world?.destroy();}
}
