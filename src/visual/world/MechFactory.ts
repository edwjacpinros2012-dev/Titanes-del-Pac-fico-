import * as THREE from 'three';
function mat(color:number,metalness=.55,roughness=.38){return new THREE.MeshStandardMaterial({color,metalness,roughness});}
function part(parent:THREE.Group,size:[number,number,number],pos:[number,number,number],color:number){const mesh=new THREE.Mesh(new THREE.BoxGeometry(...size),mat(color));mesh.position.set(...pos);mesh.castShadow=true;mesh.receiveShadow=true;parent.add(mesh);return mesh;}
export function createTitan(){const root=new THREE.Group();root.name='Titan-01';const steel=0x1b718c, dark=0x243b4b;
 part(root,[1.8,2.05,1.1],[0,2.9,0],steel);part(root,[1.25,.85,1],[0,4.35,0],0xc2d6df);part(root,[.7,.16,.12],[0,4.4,.54],0x55edff);
 part(root,[1.2,.25,.8],[0,3.85,0],0x153e52);
 for(const side of [-1,1]){part(root,[.78,1.8,.85],[side*1.25,3,0],steel);part(root,[.72,1.55,.78],[side*.82,.95,0],dark);part(root,[.78,.38,.9],[side*.82,.18,.05],0x101e2b);part(root,[.18,.9,.2],[side*1.25,2.95,.48],0x58dff0);}
 part(root,[.58,1.5,.68],[-.34,1.55,0],dark);part(root,[.58,1.5,.68],[.34,1.55,0],dark);
 const core=new THREE.PointLight(0x39dfff,2,5);core.position.set(0,3.5,.8);root.add(core);return root;}
export function createKaiju(){const root=new THREE.Group();root.name='Kaiju-01';const hide=0x527b69, armor=0x304d47;
 part(root,[2.8,2.5,1.8],[0,2.75,0],hide);part(root,[1.8,1.35,1.5],[0,4.4,.15],armor);
 for(const side of [-1,1]){part(root,[.18,.18,.12],[side*.48,4.48,.92],0xff574e);part(root,[.85,2.35,.9],[side*1.65,2.85,0],hide);part(root,[.7,1.8,.8],[side*1.1,.9,0],armor);part(root,[.3,.7,.35],[side*2.02,1.75,.2],hide);}
 const glow=new THREE.PointLight(0xff5b4d,1.7,5);glow.position.set(0,4.35,1);root.add(glow);return root;}
