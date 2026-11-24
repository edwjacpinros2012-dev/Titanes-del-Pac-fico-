import * as THREE from 'three';

/**
 * Visual direction derived from the project's 19-page concept reference.
 * These are presentation presets for the existing procedural scene, not
 * substitutes for final GLB models or authored texture maps.
 */
export interface VisualProfile {
  skyColor: number;
  fogColor: number;
  fogNear: number;
  fogFar: number;
  skyLight: number;
  groundLight: number;
  ambientIntensity: number;
  keyLight: number;
  keyIntensity: number;
  groundColor: number;
  groundRoughness: number;
  oceanColor: number;
  oceanGlow: number;
}

const PROFILES: Array<{ match: string[]; profile: VisualProfile }> = [
  {
    match: ['TORMENTA', 'LLUVIA INTENSA', 'MAREJADA'],
    profile: {
      skyColor: 0x071522, fogColor: 0x102735, fogNear: 16, fogFar: 68,
      skyLight: 0x8bbbd0, groundLight: 0x101a23, ambientIntensity: 1.35,
      keyLight: 0xa7c6d4, keyIntensity: 2.15, groundColor: 0x182b36,
      groundRoughness: 0.3, oceanColor: 0x092c3d, oceanGlow: 0x062b3c
    }
  },
  {
    match: ['NIEBLA', 'BRUMA', 'PUERTO SIN VISIBILIDAD'],
    profile: {
      skyColor: 0x172a35, fogColor: 0x526b75, fogNear: 9, fogFar: 54,
      skyLight: 0xb4cbd0, groundLight: 0x1b2529, ambientIntensity: 1.7,
      keyLight: 0xc0d3d4, keyIntensity: 1.65, groundColor: 0x263b43,
      groundRoughness: 0.46, oceanColor: 0x24414b, oceanGlow: 0x102c37
    }
  },
  {
    match: ['VIENTO', 'CIELO NUBLADO'],
    profile: {
      skyColor: 0x142635, fogColor: 0x304652, fogNear: 22, fogFar: 82,
      skyLight: 0xa8c9dc, groundLight: 0x17232b, ambientIntensity: 1.8,
      keyLight: 0xd2dce0, keyIntensity: 2.0, groundColor: 0x1c303a,
      groundRoughness: 0.58, oceanColor: 0x12384a, oceanGlow: 0x082d3d
    }
  }
];

const DEFAULT_PROFILE: VisualProfile = {
  skyColor: 0x091a27, fogColor: 0x19313e, fogNear: 23, fogFar: 78,
  skyLight: 0x9ccfff, groundLight: 0x15212b, ambientIntensity: 1.65,
  keyLight: 0xffffff, keyIntensity: 2.2, groundColor: 0x1b303b,
  groundRoughness: 0.48, oceanColor: 0x0d3446, oceanGlow: 0x082b3b
};

/** Pick a bounded cinematic lighting preset from the mission's weather label. */
export function getVisualProfile(weather: string): VisualProfile {
  const normalized = weather.toLocaleUpperCase('es');
  const selected = PROFILES.find(entry => entry.match.some(token => normalized.includes(token)));
  return { ...(selected?.profile ?? DEFAULT_PROFILE) };
}

/** Utility for future environment meshes that need the same palette. */
export function createIndustrialMaterial(color: number, roughness = 0.58): THREE.MeshStandardMaterial {
  return new THREE.MeshStandardMaterial({
    color, metalness: 0.62, roughness: Math.max(0.18, Math.min(0.92, roughness))
  });
}
