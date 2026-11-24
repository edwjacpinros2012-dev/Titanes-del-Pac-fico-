export type ResourceKey = 'alloy' | 'energy' | 'intel';
export type JaegerId = 'gipsy' | 'striker' | 'cherno';
export type JaegerRole = 'equilibrado' | 'interceptor' | 'guardian';
export type KaijuCategory = 1 | 2 | 3 | 4 | 5;
export type TechnologyId = 'composite_armor' | 'neural_link' | 'reactor_efficiency';
export interface TitanesSave {
  version: 4;
  resources: Record<ResourceKey, number>;
  unlockedMissions: number;
  completedMissions: number[];
  selectedJaeger: JaegerId;
  upgrades: Record<string, number>;
  inventory: Record<string, number>;
  buildings: Record<string, number>;
  civiliansRescued: number;
  xp: number;
  jaegerIntegrity: number;
  cityIntegrity: number;
  failedMissions: number[];
  lastMissionOutcome: 'victory' | 'defeat' | 'retreat' | null;
  productionClaimAt: number;
  rescuedMissions: number[];
  researchedTech: TechnologyId[];
  npcReputation: Record<string, number>;
  completedContracts: string[];
  tradeCount: number;
  allianceName: string;
}

const STORAGE_KEY = 'pacific-rim-titanes-save-v1';
const RESOURCE_KEYS: ResourceKey[] = ['alloy', 'energy', 'intel'];
const START: TitanesSave = {
  version: 4,
  resources: { alloy: 650, energy: 500, intel: 0 },
  unlockedMissions: 1,
  completedMissions: [],
  selectedJaeger: 'gipsy',
  upgrades: { defense: 0, reactor: 0, training: 0 },
  inventory: { repairKit: 0, armorParts: 0, researchData: 0 },
  buildings: { command: 1, hangar: 1, reactor: 1, workshop: 0, medical: 0, defense: 0, warehouse: 0, evacuation: 0 },
  civiliansRescued: 0,
  xp: 0,
  jaegerIntegrity: 100,
  cityIntegrity: 100,
  failedMissions: [],
  lastMissionOutcome: null,
  productionClaimAt: 0,
  rescuedMissions: [],
  researchedTech: [],
  npcReputation: { engineer: 0, quartermaster: 0, medic: 0 },
  completedContracts: [],
  tradeCount: 0,
  allianceName: ''
};
const cloneStart = (): TitanesSave => JSON.parse(JSON.stringify(START)) as TitanesSave;
const clamp = (n: number, min: number, max: number) => Math.max(min, Math.min(max, n));
const consecutiveMissionCount = (completed: number[]) => {
  let count = 0;
  while (completed.includes(count + 1) && count < 12) count += 1;
  return count;
};

function isValidResourceMap(values: Partial<Record<ResourceKey, number>>): boolean {
  return Object.entries(values).every(([key, value]) =>
    RESOURCE_KEYS.includes(key as ResourceKey) && Number.isSafeInteger(value) && (value as number) >= 0
  );
}

export class TitanesSystems {
  private data: TitanesSave;

  constructor() {
    this.data = this.load();
  }

  private load(): TitanesSave {
    const normalize = (value: unknown): TitanesSave | null => {
      if (!value || typeof value !== 'object') return null;
      const parsed = value as Record<string, unknown>;
      if ((parsed.version !== 1 && parsed.version !== 2 && parsed.version !== 3 && parsed.version !== 4 && parsed.version !== 5) || !parsed.resources || !Array.isArray(parsed.completedMissions)) return null;
      const numberMap = (source: unknown, defaults: Record<string, number>) => {
        const record = source && typeof source === 'object' ? source as Record<string, unknown> : {};
        return Object.fromEntries(Object.keys(defaults).map(key => {
          const rawValue = Number(record[key]);
          return [key, Number.isFinite(rawValue) ? clamp(Math.floor(rawValue), 0, 999999) : defaults[key]];
        })) as Record<string, number>;
      };
      const resources = numberMap(parsed.resources, START.resources);
      const completed = parsed.completedMissions.map(Number).filter(id => Number.isInteger(id) && id > 0 && id <= 12);
      const safe = cloneStart();
      safe.version = 5;
      safe.resources = resources as Record<ResourceKey, number>;
      safe.completedMissions = [...new Set(completed)];
      let nextMission = 1;
      while (safe.completedMissions.includes(nextMission) && nextMission < 12) nextMission += 1;
      safe.unlockedMissions = nextMission;
      const requestedJaeger = parsed.selectedJaeger === 'striker' || parsed.selectedJaeger === 'cherno' ? parsed.selectedJaeger : 'gipsy';
      const unlockedCount = consecutiveMissionCount(safe.completedMissions);
      safe.selectedJaeger = requestedJaeger === 'striker' && unlockedCount >= 2 || requestedJaeger === 'cherno' && unlockedCount >= 4 ? requestedJaeger : 'gipsy';
      safe.upgrades = numberMap(parsed.upgrades, START.upgrades);
      safe.inventory = numberMap(parsed.inventory, START.inventory);
      safe.buildings = numberMap(parsed.buildings, START.buildings);
      safe.civiliansRescued = clamp(Math.floor(Number(parsed.civiliansRescued) || 0), 0, 999999);
      safe.xp = clamp(Math.floor(Number(parsed.xp) || 0), 0, 99999999);
      safe.jaegerIntegrity = clamp(Math.floor(Number(parsed.jaegerIntegrity ?? 100) || 0), 0, 100);
      safe.cityIntegrity = clamp(Math.floor(Number(parsed.cityIntegrity ?? 100) || 0), 0, 100);
      safe.failedMissions = Array.isArray(parsed.failedMissions) ? [...new Set(parsed.failedMissions.map(Number).filter(id => Number.isInteger(id) && id > 0 && id <= 12))] : [];
      safe.lastMissionOutcome = parsed.lastMissionOutcome === 'victory' || parsed.lastMissionOutcome === 'defeat' || parsed.lastMissionOutcome === 'retreat' ? parsed.lastMissionOutcome : null;
      safe.productionClaimAt = clamp(Math.floor(Number(parsed.productionClaimAt) || 0), 0, Number.MAX_SAFE_INTEGER);
      safe.rescuedMissions = Array.isArray(parsed.rescuedMissions) ? [...new Set(parsed.rescuedMissions.map(Number).filter(id => Number.isInteger(id) && id > 0 && id <= 12))] : [];
      const techIds: TechnologyId[] = ['composite_armor', 'neural_link', 'reactor_efficiency'];
      safe.researchedTech = Array.isArray(parsed.researchedTech) ? [...new Set(parsed.researchedTech.filter((id): id is TechnologyId => techIds.includes(id as TechnologyId)))] : [];
      safe.npcReputation = numberMap(parsed.npcReputation, START.npcReputation);
      safe.completedContracts = Array.isArray(parsed.completedContracts) ? [...new Set(parsed.completedContracts.filter((id): id is string => typeof id === 'string' && ['engineer_repair','quartermaster_supply','medic_evacuation'].includes(id)))] : [];
      safe.tradeCount = clamp(Math.floor(Number(parsed.tradeCount) || 0), 0, 999999);
      safe.allianceName = typeof parsed.allianceName === 'string' ? parsed.allianceName.trim().slice(0, 24) : '';
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
          try { localStorage.setItem(STORAGE_KEY, JSON.stringify(recovered)); } catch { /* recovery remains usable in memory */ }
          return recovered;
        }
      }
    } catch { /* use safe starter state */ }
    return cloneStart();
  }

  private commit(next: TitanesSave): boolean {
    try {
      const previous = localStorage.getItem(STORAGE_KEY);
      if (previous) {
        try {
          const parsed = JSON.parse(previous) as Record<string, unknown>;
          if ((parsed.version === 1 || parsed.version === 2 || parsed.version === 3 || parsed.version === 4 || parsed.version === 5) && parsed.resources && Array.isArray(parsed.completedMissions)) {
            localStorage.setItem(STORAGE_KEY + '-backup', previous);
          }
        } catch {
          // Never replace a valid backup with a corrupt primary save.
        }
      }
      localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
      this.data = next;
      return true;
    } catch {
      return false;
    }
  }

  snapshot(): Readonly<TitanesSave> {
    return JSON.parse(JSON.stringify(this.data)) as TitanesSave;
  }

  setJaeger(id: JaegerId) {
    const required: Record<JaegerId, number> = { gipsy: 0, striker: 2, cherno: 4 };
    if (!Object.hasOwn(required, id) || consecutiveMissionCount(this.data.completedMissions) < required[id]) return false;
    const next = structuredClone(this.data);
    next.selectedJaeger = id;
    return this.commit(next);
  }

  getJaegerCombatStats() {
    const base = JAEGERS[this.data.selectedJaeger];
    const defense = this.data.upgrades.defense || 0;
    const reactor = this.data.upgrades.reactor || 0;
    const training = this.data.upgrades.training || 0;
    return {
      armor: Math.min(100, base.armor + defense * 4 + (this.data.researchedTech.includes('composite_armor') ? 8 : 0)),
      power: Math.min(120, base.power + reactor * 3 + training * 2),
      agility: Math.min(100, base.agility + training * 2 + (this.data.researchedTech.includes('neural_link') ? 8 : 0))
    };
  }

  researchTechnology(id: TechnologyId) {
    const technology = TECHNOLOGIES[id];
    if (!technology) return { ok: false, reason: 'Tecnología desconocida.' };
    if (this.data.researchedTech.includes(id)) return { ok: false, reason: 'Tecnología ya investigada.' };
    if (consecutiveMissionCount(this.data.completedMissions) < technology.requiredMissions) {
      return { ok: false, reason: 'Requiere completar ' + technology.requiredMissions + ' misiones.' };
    }
    const ok = this.transact(technology.cost, {}, next => { next.researchedTech.push(id); });
    return { ok, reason: ok ? 'Investigación completada: ' + technology.label : 'Faltan recursos o no se pudo guardar la investigación.', cost: technology.cost };
  }

  /** Defensive rating combines the perimeter, evacuation and medical infrastructure. */
  getBaseDefenseProfile() {
    const buildings = this.data.buildings;
    const perimeter = Math.max(0, buildings.defense || 0);
    const evacuation = Math.max(0, buildings.evacuation || 0);
    const medical = Math.max(0, buildings.medical || 0);
    const rating = Math.min(90, perimeter * 8 + evacuation * 4 + medical * 2);
    return {
      rating,
      cityDamageReduction: Math.min(0.65, rating / 150),
      civilianProtection: Math.min(90, evacuation * 12 + medical * 8),
      perimeterLevel: perimeter,
      evacuationLevel: evacuation,
      medicalLevel: medical
    };
  }

  storageCapacity() {
    return 2500 + Math.max(0, this.data.buildings.warehouse || 0) * 1500;
  }

  productionRates() {
    const buildings = this.data.buildings;
    return {
      alloy: Math.max(0, (buildings.workshop || 0) * 35 + (buildings.defense || 0) * 10),
      energy: Math.max(0, (buildings.reactor || 0) * 45 + (this.data.researchedTech.includes('reactor_efficiency') ? 20 : 0)),
      intel: Math.max(0, (buildings.command || 0) * 2 + (buildings.medical || 0))
    };
  }

  /** Apply validated resource changes and state updates as one persisted transaction. */
  private transact(cost: Partial<Record<ResourceKey, number>>, reward: Partial<Record<ResourceKey, number>>, update?: (next: TitanesSave) => void): boolean {
    if (!isValidResourceMap(cost) || !isValidResourceMap(reward)) return false;
    for (const key of RESOURCE_KEYS) if (this.data.resources[key] < (cost[key] ?? 0)) return false;
    const next = structuredClone(this.data);
    const capacity = this.storageCapacity();
    for (const key of RESOURCE_KEYS) {
      const amount = next.resources[key] - (cost[key] ?? 0) + (reward[key] ?? 0);
      if (!Number.isSafeInteger(amount) || amount < 0) return false;
      next.resources[key] = Math.min(capacity, amount);
    }
    update?.(next);
    return this.commit(next);
  }

  addResources(values: Partial<Record<ResourceKey, number>>) {
    return this.transact({}, values);
  }

  spendResources(cost: Partial<Record<ResourceKey, number>>) {
    return this.transact(cost, {});
  }

  buyItem(item: 'repairKit' | 'armorParts' | 'researchData', cost: Partial<Record<ResourceKey, number>>, reward: Partial<Record<ResourceKey, number>> = {}) {
    if (!isValidResourceMap(cost) || !isValidResourceMap(reward)) return false;
    if ((this.data.inventory[item] || 0) >= 999999) return false;
    return this.transact(cost, reward, next => { next.inventory[item] = (next.inventory[item] || 0) + 1; });
  }

  buyIntelData() {
    return this.transact({ energy: 120 }, { intel: 2 });
  }

  /** Exchange resources at the PPDC quartermaster. Rates are fixed and validated locally. */
  tradeResources(from: ResourceKey, to: ResourceKey, amount: number) {
    const rates: Record<ResourceKey, number> = { alloy: 1, energy: 1, intel: 1 };
    if (!RESOURCE_KEYS.includes(from) || !RESOURCE_KEYS.includes(to) || from === to || !Number.isSafeInteger(amount) || amount < 10 || amount > 1000) {
      return { ok: false, reason: 'Intercambio inválido. Elige entre 10 y 1.000 unidades.' };
    }
    const output = Math.floor(amount * rates[from] / rates[to]);
    const ok = this.transact({ [from]: amount }, { [to]: output }, next => { next.tradeCount += 1; next.npcReputation.quartermaster = Math.min(100, next.npcReputation.quartermaster + 1); });
    return { ok, received: ok ? output : 0, reason: ok ? 'Intercambio completado con el intendente.' : 'Recursos insuficientes o almacén lleno.' };
  }

  /** NPC contracts are finite, claim-once tasks; rewards are committed atomically. */
  completeNpcContract(id: string) {
    const contracts: Record<string, { cost: Partial<Record<ResourceKey, number>>; reward: Partial<Record<ResourceKey, number>>; reputation: string; xp: number }> = {
      engineer_repair: { cost: { alloy: 90, energy: 40 }, reward: { energy: 150 }, reputation: 'engineer', xp: 35 },
      quartermaster_supply: { cost: { alloy: 120 }, reward: { energy: 100, intel: 1 }, reputation: 'quartermaster', xp: 40 },
      medic_evacuation: { cost: { energy: 80 }, reward: { alloy: 90, intel: 1 }, reputation: 'medic', xp: 45 }
    };
    const contract = contracts[id];
    if (!contract || this.data.completedContracts.includes(id)) return { ok: false, reason: 'Contrato desconocido o ya reclamado.' };
    const ok = this.transact(contract.cost, contract.reward, next => {
      next.completedContracts.push(id);
      next.npcReputation[contract.reputation] = Math.min(100, (next.npcReputation[contract.reputation] || 0) + 10);
      next.xp += contract.xp;
    });
    return { ok, reason: ok ? 'Contrato completado. Recompensa y reputación guardadas.' : 'Faltan recursos o espacio en el almacén.' };
  }

  setAllianceName(name: string) {
    const clean = name.trim().replace(/[^\\p{L}\\p{N} _-]/gu, '').slice(0, 24);
    if (clean.length < 3) return { ok: false, reason: 'El nombre debe tener entre 3 y 24 caracteres.' };
    if (this.data.buildings.command < 1 || this.data.upgrades.defense < 2) return { ok: false, reason: 'Requiere centro de mando y base nivel 2.' };
    const next = structuredClone(this.data);
    next.allianceName = clean;
    return { ok: this.commit(next), reason: 'Alianza guardada en esta partida local. La red online aún no está conectada.' };
  }

  upgrade(key: keyof TitanesSave['upgrades']) {
    if (!Object.hasOwn(this.data.upgrades, key)) return { ok: false, cost: { alloy: 0, energy: 0 }, level: 0 };
    const level = this.data.upgrades[key] ?? 0;
    if (!Number.isSafeInteger(level) || level < 0 || level >= 10) return { ok: false, cost: { alloy: 0, energy: 0 }, level, reason: 'Nivel máximo alcanzado.' };
    const cost = { alloy: 180 + level * 140, energy: 120 + level * 100 };
    const ok = this.transact(cost, {}, next => { next.upgrades[key] = level + 1; });
    return { ok, cost, level: ok ? level + 1 : level };
  }

  upgradeBuilding(id: keyof TitanesSave['buildings']) {
    if (!Object.hasOwn(this.data.buildings, id)) return { ok: false, level: 0, reason: 'Instalación desconocida.' };
    const level = this.data.buildings[id] || 0;
    if (!Number.isSafeInteger(level) || level < 0 || level >= 10) return { ok: false, level, reason: 'Nivel máximo de instalación alcanzado.' };
    if (id === 'command') return { ok: false, level, reason: 'El centro de mando se mejora mediante progresión de base.' };
    const baseLevel = 1 + Math.floor((this.data.upgrades.defense || 0) / 2);
    const unlockAt: Record<string, number> = { hangar: 1, reactor: 1, workshop: 1, medical: 1, defense: 1, warehouse: 1, evacuation: 2 };
    if (baseLevel < (unlockAt[id] || 1)) return { ok: false, level, reason: 'Requiere base nivel ' + (unlockAt[id] || 1) };
    const cost = { alloy: 160 + level * 125, energy: 90 + level * 80 };
    const ok = this.transact(cost, {}, next => { next.buildings[id] = level + 1; });
    return ok ? { ok: true, level: level + 1, cost } : { ok: false, level, reason: 'Recursos insuficientes o no se pudo guardar la partida.' };
  }

  collectProduction() {
    const rates = this.productionRates();
    if (!rates.alloy && !rates.energy && !rates.intel) {
      return { ok: false, reward: { alloy: 0, energy: 0, intel: 0 }, reason: 'Mejora el taller o reactor para activar producción.' };
    }
    const lastClaim = this.data.productionClaimAt;
    const now = Date.now();
    const elapsedHours = lastClaim > 0 ? clamp((now - lastClaim) / 3600000, 0, 8) : 1;
    if (elapsedHours < 0.05) {
      return { ok: false, reward: { alloy: 0, energy: 0, intel: 0 }, remainingMs: (0.05 - elapsedHours) * 3600000, reason: 'La producción todavía se está acumulando.' };
    }
    const capacity = this.storageCapacity();
    const reward = {
      alloy: Math.min(Math.floor(rates.alloy * elapsedHours), Math.max(0, capacity - this.data.resources.alloy)),
      energy: Math.min(Math.floor(rates.energy * elapsedHours), Math.max(0, capacity - this.data.resources.energy)),
      intel: Math.min(Math.floor(rates.intel * elapsedHours), Math.max(0, capacity - this.data.resources.intel))
    };
    if (!reward.alloy && !reward.energy && !reward.intel) {
      return { ok: false, reward, reason: 'Almacén lleno o producción todavía en curso. Mejora el almacén.' };
    }
    if (!this.transact({}, reward, next => { next.productionClaimAt = now; })) return { ok: false, reward: { alloy: 0, energy: 0, intel: 0 }, reason: 'No se pudo guardar la producción.' };
    return { ok: true, reward, elapsedHours, remainingMs: 8 * 3600000 };
  }

  rescueCivilians(count: number, missionId = this.data.unlockedMissions) {
    if (!Number.isSafeInteger(count) || count <= 0 || count > 100 ||
        missionId !== this.data.unlockedMissions ||
        this.data.completedMissions.includes(missionId) ||
        this.data.rescuedMissions.includes(missionId) ||
        count > Math.floor((Number.MAX_SAFE_INTEGER - this.data.civiliansRescued) / 8) ||
        count > Math.floor((Number.MAX_SAFE_INTEGER - this.data.xp) / 5)) {
      return { ok: false, rescued: 0, total: this.data.civiliansRescued, reason: 'Rescate no disponible o ya completado.' };
    }
    const reward = { alloy: count * 8, energy: count * 4 };
    if (!isValidResourceMap(reward)) return { ok: false, rescued: 0, total: this.data.civiliansRescued, reason: 'Recompensa inválida.' };
    const ok = this.transact({}, reward, next => {
      next.civiliansRescued += count;
      next.xp += count * 5;
      next.rescuedMissions.push(missionId);
    });
    return { ok, rescued: ok ? count : 0, total: this.data.civiliansRescued, reason: ok ? 'Civiles evacuados y guardados.' : 'No se pudo guardar el rescate.' };
  }

  resolveMission(missionId: number, outcome: 'victory' | 'defeat' | 'retreat', jaegerDamage = 0, cityDamage = 0) {
    const emptyReward = { alloy: 0, energy: 0, intel: 0, xp: 0 };
    if (!Number.isInteger(missionId) || missionId !== this.data.unlockedMissions || this.data.completedMissions.includes(missionId)) return { ok: false, outcome, reward: emptyReward, unlocks: [] as string[], reason: 'Misión no disponible.' };
    if (!['victory', 'defeat', 'retreat'].includes(outcome) || !Number.isSafeInteger(jaegerDamage) || jaegerDamage < 0 || jaegerDamage > 100 || !Number.isSafeInteger(cityDamage) || cityDamage < 0 || cityDamage > 100) return { ok: false, outcome, reward: emptyReward, unlocks: [] as string[], reason: 'Resultado de misión inválido.' };
    const reward = outcome === 'victory' ? getMissionReward(missionId) : emptyReward;
    const defenseProfile = this.getBaseDefenseProfile();
    const mitigatedCityDamage = Math.max(0, Math.floor(cityDamage * (1 - defenseProfile.cityDamageReduction)));
    const previousUnlocks = getCampaignUnlocks(this.data.completedMissions);
    const ok = this.transact({}, { alloy: reward.alloy, energy: reward.energy, intel: reward.intel }, next => {
      next.jaegerIntegrity = Math.max(0, next.jaegerIntegrity - jaegerDamage);
      next.cityIntegrity = Math.max(0, next.cityIntegrity - mitigatedCityDamage);
      next.lastMissionOutcome = outcome;
      if (outcome === 'victory') {
        next.completedMissions.push(missionId);
        next.unlockedMissions = Math.min(12, missionId + 1);
        next.xp += reward.xp;
      } else if (!next.failedMissions.includes(missionId)) next.failedMissions.push(missionId);
    });
    if (!ok) return { ok: false, outcome, reward: emptyReward, unlocks: [] as string[], reason: 'No se pudo guardar el resultado.' };
    const unlocks = outcome === 'victory' ? getCampaignUnlocks(this.data.completedMissions).filter(item => !previousUnlocks.includes(item)) : [];
    return { ok: true, outcome, reward, unlocks, jaegerIntegrity: this.data.jaegerIntegrity, cityIntegrity: this.data.cityIntegrity, cityDamageApplied: mitigatedCityDamage, defenseRating: defenseProfile.rating };
  }

  repairJaeger() {
    const integrity = this.data.jaegerIntegrity;
    if (integrity >= 100) return { ok: false, integrity, reason: 'El Jaeger no necesita reparación.' };
    if ((this.data.inventory.repairKit || 0) > 0) {
      const ok = this.transact({}, {}, next => { next.inventory.repairKit -= 1; next.jaegerIntegrity = Math.min(100, next.jaegerIntegrity + 40); });
      return { ok, integrity: this.data.jaegerIntegrity, reason: ok ? 'Kit de reparación utilizado.' : 'No se pudo guardar la reparación.' };
    }
    if ((this.data.inventory.armorParts || 0) > 0) {
      const ok = this.transact({}, {}, next => { next.inventory.armorParts -= 1; next.jaegerIntegrity = Math.min(100, next.jaegerIntegrity + 20); });
      return { ok, integrity: this.data.jaegerIntegrity, reason: ok ? 'Componentes de armadura instalados.' : 'No se pudo guardar la reparación.' };
    }
    const ok = this.transact({ alloy: 120, energy: 80 }, {}, next => { next.jaegerIntegrity = Math.min(100, next.jaegerIntegrity + 35); });
    return { ok, integrity: this.data.jaegerIntegrity, reason: ok ? 'Reparación de taller completada.' : 'Se requieren 120 aleación y 80 energía.' };
  }

  missionStatus(id: number) {
    const completed = this.data.completedMissions.includes(id);
    return { unlocked: id <= this.data.unlockedMissions, completed, current: id === this.data.unlockedMissions && !completed, reward: getMissionReward(id), unlocks: getMissionMilestones(id) };
  }

  campaignProgress() {
    const completed = consecutiveMissionCount(this.data.completedMissions);
    const rank = getCampaignRank(this.data.xp);
    return {
      completed,
      total: 12,
      xp: this.data.xp,
      rank,
      campaignComplete: completed === 12,
      unlockedJaegers: getUnlockedJaegers(this.data.completedMissions)
    };
  }

  reset() {
    this.commit(cloneStart());
  }
}

export const JAEGERS: Record<JaegerId, { label: string; role: string; category: JaegerRole; specialty: string; passive: string; armor: number; power: number; agility: number }> = {
  gipsy: { label: 'GIPSY-CLASS · MARK-I', role: 'Equilibrado', category: 'equilibrado', specialty: 'Versátil · primera línea', passive: 'Sin penalización de movilidad ni defensa', armor: 58, power: 52, agility: 46 },
  striker: { label: 'STRIKER-CLASS', role: 'Interceptor', category: 'interceptor', specialty: 'Movilidad y respuesta rápida', passive: 'Bonificación de agilidad para reposicionarse', armor: 72, power: 91, agility: 88 },
  cherno: { label: 'CHERNO-CLASS', role: 'Guardián pesado', category: 'guardian', specialty: 'Resistencia y protección urbana', passive: 'Bonificación de armadura para resistir presión', armor: 95, power: 68, agility: 48 }
};

export const KAIJU_ARCHETYPES: Array<{ id: string; name: string; category: KaijuCategory; archetype: string; threat: string; trait: string; counterplay: string }> = [
  { id: 'raker', name: 'RAKER', category: 1, archetype: 'Explorador', threat: 'Baja', trait: 'Ligero y veloz; busca puntos débiles del perímetro', counterplay: 'Priorizar detección temprana y evacuación rápida' },
  { id: 'brineback', name: 'BRINEBACK', category: 2, archetype: 'Blindado', threat: 'Moderada', trait: 'Placas densas y avance constante', counterplay: 'Coordinar unidades y proteger infraestructura crítica' },
  { id: 'razorfin', name: 'RAZORFIN', category: 3, archetype: 'Acuático', threat: 'Alta', trait: 'Se desplaza con rapidez por zonas costeras', counterplay: 'Activar sensores costeros y cerrar rutas vulnerables' },
  { id: 'dreadmaw', name: 'DREADMAW', category: 4, archetype: 'Asedio', threat: 'Muy alta', trait: 'Gran resistencia y presión prolongada sobre la ciudad', counterplay: 'Reforzar el perímetro, mantener el reactor y evacuar sectores' },
  { id: 'abyssal-crown', name: 'ABYSSAL CROWN', category: 5, archetype: 'Colosal', threat: 'Extrema', trait: 'Amenaza de escala estratégica con gran impacto territorial', counterplay: 'Despliegue coordinado, base avanzada y protección civil máxima' }
];

export const TECHNOLOGIES: Record<TechnologyId, { label: string; description: string; requiredMissions: number; cost: Partial<Record<ResourceKey, number>> }> = {
  composite_armor: { label: 'Blindaje compuesto', description: '+8 armadura para el Jaeger', requiredMissions: 1, cost: { alloy: 260, energy: 160, intel: 2 } },
  neural_link: { label: 'Interfaz neuronal', description: '+8 agilidad para el Jaeger', requiredMissions: 2, cost: { alloy: 180, energy: 240, intel: 3 } },
  reactor_efficiency: { label: 'Reactor de alto rendimiento', description: '+20 energía por hora en la base', requiredMissions: 3, cost: { alloy: 220, energy: 180, intel: 2 } }
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

export function getMissionMilestones(id: number): string[] {
  return CAMPAIGN_MILESTONES[id] ? [...CAMPAIGN_MILESTONES[id]] : [];
}

export function getCampaignUnlocks(completed: number[]): string[] {
  return Object.entries(CAMPAIGN_MILESTONES)
    .filter(([mission]) => completed.includes(Number(mission)))
    .flatMap(([, items]) => items);
}

export function getUnlockedJaegers(completed: number[]): JaegerId[] {
  const count = consecutiveMissionCount(completed);
  return (['gipsy', 'striker', 'cherno'] as JaegerId[]).filter(id => count >= ({ gipsy: 0, striker: 2, cherno: 4 }[id]));
}

export function getCampaignRank(xp: number): string {
  if (xp >= 3000) return 'MARSHAL';
  if (xp >= 1600) return 'VETERANO';
  if (xp >= 800) return 'PILOTO ELITE';
  if (xp >= 300) return 'PILOTO';
  return 'CADETE';
}
