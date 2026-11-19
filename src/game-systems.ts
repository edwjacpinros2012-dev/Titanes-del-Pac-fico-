export type ResourceKey = 'alloy' | 'energy' | 'intel';
export type JaegerId = 'gipsy' | 'striker' | 'cherno';
export interface TitanesSave {
  version: 1;
  resources: Record<ResourceKey, number>;
  unlockedMissions: number;
  completedMissions: number[];
  selectedJaeger: JaegerId;
  upgrades: Record<string, number>;
  xp: number;
}
const STORAGE_KEY = 'pacific-rim-titanes-save-v1';
const START: TitanesSave = {
  version: 1, resources: { alloy: 650, energy: 500, intel: 0 },
  unlockedMissions: 1, completedMissions: [], selectedJaeger: 'gipsy',
  upgrades: { defense: 0, reactor: 0, training: 0 }, xp: 0
};
const cloneStart = (): TitanesSave => JSON.parse(JSON.stringify(START)) as TitanesSave;
const clamp = (n: number, min: number, max: number) => Math.max(min, Math.min(max, n));

export class TitanesSystems {
  private data: TitanesSave;
  constructor() { this.data = this.load(); }
  private load(): TitanesSave {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (!raw) return cloneStart();
      const parsed = JSON.parse(raw) as Partial<TitanesSave>;
      if (parsed.version !== 1 || !parsed.resources || !Array.isArray(parsed.completedMissions)) return cloneStart();
      return { ...cloneStart(), ...parsed, resources: { ...START.resources, ...parsed.resources }, upgrades: { ...START.upgrades, ...parsed.upgrades } } as TitanesSave;
    } catch { return cloneStart(); }
  }
  private save() { try { localStorage.setItem(STORAGE_KEY, JSON.stringify(this.data)); } catch { /* storage may be disabled */ } }
  snapshot(): Readonly<TitanesSave> { return JSON.parse(JSON.stringify(this.data)) as TitanesSave; }
  setJaeger(id: JaegerId) { this.data.selectedJaeger = id; this.save(); }
  addResources(values: Partial<Record<ResourceKey, number>>) {
    for (const key of Object.keys(values) as ResourceKey[]) this.data.resources[key] = clamp(this.data.resources[key] + Math.max(0, values[key] ?? 0), 0, 999999);
    this.save();
  }
  spendResources(cost: Partial<Record<ResourceKey, number>>) {
    for (const key of Object.keys(cost) as ResourceKey[]) if (this.data.resources[key] < Math.max(0, cost[key] ?? 0)) return false;
    for (const key of Object.keys(cost) as ResourceKey[]) this.data.resources[key] -= Math.max(0, cost[key] ?? 0);
    this.save();
    return true;
  }
  upgrade(key: keyof TitanesSave['upgrades']) {
    const level = this.data.upgrades[key] ?? 0;
    const cost = { alloy: 180 + level * 140, energy: 120 + level * 100 };
    if (this.data.resources.alloy < cost.alloy || this.data.resources.energy < cost.energy) return { ok: false, cost, level };
    this.data.resources.alloy -= cost.alloy; this.data.resources.energy -= cost.energy;
    this.data.upgrades[key] = level + 1; this.save();
    return { ok: true, cost, level: level + 1 };
  }
  completeMission(missionId: number) {
    if (missionId !== this.data.unlockedMissions || this.data.completedMissions.includes(missionId)) return { ok: false, reward: { alloy: 0, energy: 0, intel: 0 } };
    const reward = { alloy: 240 + missionId * 60, energy: 180 + missionId * 40, intel: 1 };
    this.data.completedMissions.push(missionId);
    this.data.unlockedMissions = Math.min(12, missionId + 1);
    this.data.xp += 100 + missionId * 25;
    this.addResources(reward);
    this.save();
    return { ok: true, reward };
  }
  missionStatus(id: number) {
    return { unlocked: id <= this.data.unlockedMissions, completed: this.data.completedMissions.includes(id), current: id === this.data.unlockedMissions };
  }
  reset() { this.data = cloneStart(); this.save(); }
}
export const JAEGERS: Record<JaegerId, { label: string; role: string; armor: number; power: number; agility: number }> = {
  gipsy: { label: 'GIPSY-CLASS', role: 'Equilibrado', armor: 86, power: 74, agility: 62 },
  striker: { label: 'STRIKER-CLASS', role: 'Rápido', armor: 72, power: 91, agility: 88 },
  cherno: { label: 'CHERNO-CLASS', role: 'Pesado', armor: 95, power: 68, agility: 48 }
};
export const MISSION_LIST = [
  { id: 1, name: 'DEFENSA DE LA COSTA', sector: 'SECTOR 07', description: 'Entrenamiento de despliegue y reconocimiento.' },
  { id: 2, name: 'ALERTA EN EL PUERTO', sector: 'SECTOR 08', description: 'Recupera el perímetro portuario.' },
  { id: 3, name: 'BRECHA DE CONTENCIÓN', sector: 'SECTOR 09', description: 'Asegura la zona de contención.' },
  { id: 4, name: 'CIUDAD EN PELIGRO', sector: 'SECTOR 10', description: 'Protege la infraestructura costera.' },
  { id: 5, name: 'OPERACIÓN DE RESCATE', sector: 'SECTOR 11', description: 'Completa la extracción y vuelve al Shatterdome.' }
] as const;
