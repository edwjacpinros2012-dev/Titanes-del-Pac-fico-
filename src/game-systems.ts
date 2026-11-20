export type ResourceKey = 'alloy' | 'energy' | 'intel';
export type JaegerId = 'gipsy' | 'striker' | 'cherno';
export interface TitanesSave {
  version: 1;
  resources: Record<ResourceKey, number>;
  unlockedMissions: number;
  completedMissions: number[];
  selectedJaeger: JaegerId;
  upgrades: Record<string, number>;
  inventory: Record<string, number>;
  buildings: Record<string, number>;
  civiliansRescued: number;
  xp: number;
}
const STORAGE_KEY = 'pacific-rim-titanes-save-v1';
const START: TitanesSave = {
  version: 1, resources: { alloy: 650, energy: 500, intel: 0 },
  unlockedMissions: 1, completedMissions: [], selectedJaeger: 'gipsy',
  upgrades: { defense: 0, reactor: 0, training: 0 }, inventory: { repairKit: 0, armorParts: 0, researchData: 0 }, buildings: { command: 1, hangar: 1, reactor: 1, workshop: 0, medical: 0, defense: 0, evacuation: 0 }, civiliansRescued: 0, xp: 0
};
const cloneStart = (): TitanesSave => JSON.parse(JSON.stringify(START)) as TitanesSave;
const clamp = (n: number, min: number, max: number) => Math.max(min, Math.min(max, n));
const consecutiveMissionCount = (completed: number[]) => { let count = 0; while (completed.includes(count + 1) && count < 12) count += 1; return count; };

export class TitanesSystems {
  private data: TitanesSave;
  constructor() { this.data = this.load(); }
  private load(): TitanesSave {
    const normalize = (value: unknown): TitanesSave | null => {
      if (!value || typeof value !== 'object') return null;
      const parsed = value as Partial<TitanesSave>;
      if (parsed.version !== 1 || !parsed.resources || !Array.isArray(parsed.completedMissions)) return null;
      const numberMap = (source: unknown, defaults: Record<string, number>) => {
        const record = source && typeof source === 'object' ? source as Record<string, unknown> : {};
        return Object.fromEntries(Object.keys(defaults).map(key => {
          const rawValue = Number(record[key]);
          return [key, Number.isFinite(rawValue) ? clamp(Math.floor(rawValue), 0, 999999) : defaults[key]];
        })) as Record<string, number>;
      };
      const resources = numberMap(parsed.resources, START.resources);
      const selected = parsed.selectedJaeger;
      const completed = parsed.completedMissions.map(Number).filter(id => Number.isInteger(id) && id > 0 && id <= 12);
      const safe = cloneStart();
      safe.resources = resources as Record<ResourceKey, number>;
      safe.completedMissions = [...new Set(completed)];
      // Mission access is derived from consecutive completions; a damaged or edited save cannot skip the campaign.
      let nextMission = 1;
      while (safe.completedMissions.includes(nextMission) && nextMission < 12) nextMission += 1;
      safe.unlockedMissions = nextMission;
      safe.selectedJaeger = selected === 'striker' || selected === 'cherno' ? selected : 'gipsy';
      safe.upgrades = numberMap(parsed.upgrades, START.upgrades);
      safe.inventory = numberMap(parsed.inventory, START.inventory);
      safe.buildings = numberMap(parsed.buildings, START.buildings);
      safe.civiliansRescued = clamp(Math.floor(Number(parsed.civiliansRescued) || 0), 0, 999999);
      safe.xp = clamp(Math.floor(Number(parsed.xp) || 0), 0, 99999999);
      return safe;
    };
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) {
        const current = normalize(JSON.parse(raw));
        if (current) return current;
      }
    } catch { /* try backup below */ }
    try {
      const backup = localStorage.getItem(STORAGE_KEY + '-backup');
      if (backup) {
        const recovered = normalize(JSON.parse(backup));
        if (recovered) {
          try { localStorage.setItem(STORAGE_KEY, JSON.stringify(recovered)); } catch { /* recovery is still usable in memory */ }
          return recovered;
        }
      }
    } catch { /* use safe starter state */ }
    return cloneStart();
  }
  private save() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) {
        try {
          const parsed = JSON.parse(raw) as Partial<TitanesSave>;
          if (parsed.version === 1 && parsed.resources && Array.isArray(parsed.completedMissions)) localStorage.setItem(STORAGE_KEY + '-backup', raw);
        } catch { /* never replace backup with corrupted data */ }
      }
      localStorage.setItem(STORAGE_KEY, JSON.stringify(this.data));
    } catch { /* storage may be disabled or full; gameplay remains in memory */ }
  }
  snapshot(): Readonly<TitanesSave> { return JSON.parse(JSON.stringify(this.data)) as TitanesSave; }
  setJaeger(id: JaegerId) { const required: Record<JaegerId, number> = { gipsy: 0, striker: 2, cherno: 4 }; if (consecutiveMissionCount(this.data.completedMissions) < required[id]) return false; this.data.selectedJaeger = id; this.save(); return true; }
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
  buyItem(item: 'repairKit' | 'armorParts' | 'researchData', cost: Partial<Record<ResourceKey, number>>) {
    if (!this.spendResources(cost)) return false;
    this.data.inventory[item] = (this.data.inventory[item] || 0) + 1;
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
  upgradeBuilding(id: keyof TitanesSave['buildings']) {
    const level = this.data.buildings[id] || 0;
    if (id === 'command') return { ok: false, level, reason: 'El centro de mando se mejora mediante progresión de base.' };
    const baseLevel = 1 + Math.floor((this.data.upgrades.defense || 0) / 2);
    const unlockAt: Record<string, number> = { hangar: 1, reactor: 1, workshop: 1, medical: 1, defense: 1, evacuation: 2 };
    if (baseLevel < (unlockAt[id] || 1)) return { ok: false, level, reason: 'Requiere base nivel ' + (unlockAt[id] || 1) };
    const cost = { alloy: 160 + level * 125, energy: 90 + level * 80 };
    if (!this.spendResources(cost)) return { ok: false, level, reason: 'Recursos insuficientes' };
    this.data.buildings[id] = level + 1;
    this.save();
    return { ok: true, level: level + 1, cost };
  }
  collectProduction() {
    const buildings = this.data.buildings;
    const reward = {
      alloy: Math.max(0, (buildings.workshop || 0) * 35 + (buildings.defense || 0) * 10),
      energy: Math.max(0, (buildings.reactor || 0) * 45),
      intel: Math.max(0, (buildings.command || 0) * 2 + (buildings.medical || 0))
    };
    if (!reward.alloy && !reward.energy && !reward.intel) return { ok: false, reward, reason: 'Mejora el generador, taller, centro médico o mando para activar producción.' };
    const productionKey = STORAGE_KEY + '-production-last-claim';
    const cooldownMs = 60 * 60 * 1000;
    let lastClaim = 0;
    try { lastClaim = Math.max(0, Number(localStorage.getItem(productionKey)) || 0); } catch { /* local storage unavailable */ }
    const now = Date.now();
    const remaining = cooldownMs - (now - lastClaim);
    if (lastClaim > 0 && remaining > 0) return { ok: false, reward: { alloy: 0, energy: 0, intel: 0 }, remainingMs: remaining, reason: 'La producción ya fue reclamada. Vuelve cuando termine el ciclo de 60 minutos.' };
    this.addResources(reward);
    try { localStorage.setItem(productionKey, String(now)); } catch { /* still grant once for this session */ }
    return { ok: true, reward, remainingMs: cooldownMs };
  }
  rescueCivilians(count: number) {
    const safeCount = Math.max(0, Math.floor(count));
    this.data.civiliansRescued += safeCount;
    this.data.xp += safeCount * 5;
    this.addResources({ alloy: safeCount * 8, energy: safeCount * 4 });
    this.save();
    return { rescued: safeCount, total: this.data.civiliansRescued };
  }
  completeMission(missionId: number) {
    if (missionId !== this.data.unlockedMissions || this.data.completedMissions.includes(missionId)) {
      return { ok: false, reward: { alloy: 0, energy: 0, intel: 0, xp: 0 }, unlocks: [] as string[] };
    }
    const reward = getMissionReward(missionId);
    const previouslyUnlocked = getCampaignUnlocks(this.data.completedMissions);
    this.data.completedMissions.push(missionId);
    this.data.unlockedMissions = Math.min(12, missionId + 1);
    this.data.xp += reward.xp;
    this.addResources({ alloy: reward.alloy, energy: reward.energy, intel: reward.intel });
    const unlocks = getCampaignUnlocks(this.data.completedMissions).filter(item => !previouslyUnlocked.includes(item));
    this.save();
    return { ok: true, reward, unlocks };
  }
  missionStatus(id: number) {
    const completed = this.data.completedMissions.includes(id);
    return { unlocked: id <= this.data.unlockedMissions, completed, current: id === this.data.unlockedMissions && !completed, reward: getMissionReward(id), unlocks: getMissionMilestones(id) };
  }
  campaignProgress() {
    const completed = consecutiveMissionCount(this.data.completedMissions);
    const rank = getCampaignRank(this.data.xp);
    return { completed, total: 12, xp: this.data.xp, rank, campaignComplete: Array.from({ length: 12 }, (_, i) => i + 1).every(id => this.data.completedMissions.includes(id)), unlockedJaegers: getUnlockedJaegers(this.data.completedMissions) };
  }
  reset() { this.data = cloneStart(); this.save(); }
}
export const JAEGERS: Record<JaegerId, { label: string; role: string; armor: number; power: number; agility: number }> = {
  gipsy: { label: 'GIPSY-CLASS · MARK-I', role: 'Jaeger inicial · Nivel 1', armor: 58, power: 52, agility: 46 },
  striker: { label: 'STRIKER-CLASS', role: 'Rápido', armor: 72, power: 91, agility: 88 },
  cherno: { label: 'CHERNO-CLASS', role: 'Pesado', armor: 95, power: 68, agility: 48 }
};
export const MISSION_LIST = [
  { id: 1, name: 'DEFENSA DE LA COSTA', sector: 'SECTOR 07', description: 'Entrenamiento de despliegue y reconocimiento.' },
  { id: 2, name: 'ALERTA EN EL PUERTO', sector: 'SECTOR 08', description: 'Recupera el perímetro portuario.' },
  { id: 3, name: 'BRECHA DE CONTENCIÓN', sector: 'SECTOR 09', description: 'Asegura la zona de contención.' },
  { id: 4, name: 'CIUDAD EN PELIGRO', sector: 'SECTOR 10', description: 'Protege la infraestructura costera.' },
  { id: 5, name: 'OPERACIÓN DE RESCATE', sector: 'SECTOR 11', description: 'Completa la extracción y vuelve al Shatterdome.' },
  { id: 6, name: 'RUTA DE SUMINISTROS', sector: 'SECTOR 12', description: 'Asegura el corredor de abastecimiento.' },
  { id: 7, name: 'ALERTA DE FRONTERA', sector: 'SECTOR 13', description: 'Refuerza la vigilancia de la zona.' },
  { id: 8, name: 'RECUPERACIÓN DE DATOS', sector: 'SECTOR 14', description: 'Recupera inteligencia para la PPDC.' },
  { id: 9, name: 'DEFENSA DEL SHATTERDOME', sector: 'SECTOR 15', description: 'Responde a una alerta en la base.' },
  { id: 10, name: 'EVACUACIÓN COSTERA', sector: 'SECTOR 16', description: 'Coordina la evacuación de civiles.' },
  { id: 11, name: 'PATRULLA DE LA BRECHA', sector: 'SECTOR 17', description: 'Explora el perímetro de la brecha.' },
  { id: 12, name: 'ÚLTIMA LÍNEA', sector: 'SECTOR 18', description: 'Completa la operación final de la campaña inicial.' }
] as const;

export interface MissionReward { alloy: number; energy: number; intel: number; xp: number; }
const CAMPAIGN_MILESTONES: Record<number, string[]> = {
  2: ['Jaeger Striker disponible en hangar'],
  4: ['Jaeger Cherno disponible en hangar'],
  12: ['Campaña inicial completada · rango final disponible']
};
export function getMissionReward(id: number): MissionReward {
  if (!Number.isInteger(id) || id < 1 || id > 12) return { alloy: 0, energy: 0, intel: 0, xp: 0 };
  return { alloy: 240 + id * 60, energy: 180 + id * 40, intel: 1 + Math.floor((id - 1) / 4), xp: 100 + id * 25 };
}
export function getMissionMilestones(id: number): string[] { return CAMPAIGN_MILESTONES[id] ? [...CAMPAIGN_MILESTONES[id]] : []; }
export function getCampaignUnlocks(completed: number[]): string[] { return Object.entries(CAMPAIGN_MILESTONES).filter(([mission]) => completed.includes(Number(mission))).flatMap(([, items]) => items); }
export function getUnlockedJaegers(completed: number[]): JaegerId[] {
  const count = consecutiveMissionCount(completed);
  return (['gipsy','striker','cherno'] as JaegerId[]).filter(id => count >= ({gipsy:0,striker:2,cherno:4}[id]));
}
export function getCampaignRank(xp: number): string {
  if (xp >= 3000) return 'MARSHAL';
  if (xp >= 1600) return 'VETERANO';
  if (xp >= 800) return 'PILOTO ELITE';
  if (xp >= 300) return 'PILOTO';
  return 'CADETE';
}
