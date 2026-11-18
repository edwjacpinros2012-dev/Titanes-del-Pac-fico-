import * as THREE from 'three';
import { createTitan, createKaiju } from './MechFactory';
export class World3D {
 readonly scene=new THREE.Scene();
 readonly camera=new THREE.PerspectiveCamera(55,1,.1,180);
 readonly renderer:THREE.WebGLRenderer;
 readonly titan=createTitan();
 readonly kaiju=createKaiju();
 private resizeObserver:ResizeObserver;
 constructor(private canvas:HTMLCanvasElement,private host:HTMLElement){
  this.scene.background=new THREE.Color(0x071522);this.scene.fog=new THREE.Fog(0x071522,28,100);
  this.camera.position.set(0,8,17);
  this.renderer=new THREE.WebGLRenderer({canvas,antialias:true,alpha:false});
  this.renderer.setPixelRatio(Math.min(window.devicePixelRatio||1,1.6));this.renderer.shadowMap.enabled=true;this.renderer.toneMapping=THREE.ACESFilmicToneMapping;
  this.scene.add(new THREE.HemisphereLight(0xa8d9ff,0x182a32,2));
  const key=new THREE.DirectionalLight(0xe1f6ff,2.8);key.position.set(-12,22,10);key.castShadow=true;this.scene.add(key);
  const floor=new THREE.Mesh(new THREE.PlaneGeometry(180,180),new THREE.MeshStandardMaterial({color:0x142b38,metalness:.3,roughness:.8}));floor.rotation.x=-Math.PI/2;floor.receiveShadow=true;this.scene.add(floor);
  const grid=new THREE.GridHelper(120,60,0x23768a,0x173c50);grid.position.y=.015;this.scene.add(grid);
  for(let i=0;i<32;i++){const height=3+Math.random()*11,x=(Math.random()-.5)*65,z=-15-Math.random()*55;const b=new THREE.Mesh(new THREE.BoxGeometry(2+Math.random()*4,height,2+Math.random()*3),new THREE.MeshStandardMaterial({color:0x1c3545,metalness:.35,roughness:.65}));b.position.set(x,height/2,z);b.castShadow=true;this.scene.add(b);}
  this.titan.position.set(-3,0,4);this.kaiju.position.set(4,0,-9);this.scene.add(this.titan,this.kaiju);
  this.resizeObserver=new ResizeObserver(()=>this.resize());this.resizeObserver.observe(host);this.resize();
 }
 resize(){const w=Math.max(1,this.host.clientWidth),h=Math.max(1,this.host.clientHeight);this.camera.aspect=w/h;this.camera.updateProjectionMatrix();this.renderer.setSize(w,h,false);}
 render(time:number){this.kaiju.rotation.y=Math.sin(time*.00045)*.1;this.camera.position.lerp(new THREE.Vector3(this.titan.position.x,7.5,this.titan.position.z+14),.045);this.camera.lookAt(this.titan.position.x,2,this.titan.position.z-3);this.renderer.render(this.scene,this.camera);}
 destroy(){this.resizeObserver.disconnect();this.renderer.dispose();}
}
