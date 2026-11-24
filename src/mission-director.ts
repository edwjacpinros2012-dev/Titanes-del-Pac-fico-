import type { TitanesSystems } from './game-systems';
import { KAIJU_ARCHETYPES, MISSION_LIST } from './game-systems';

export interface MissionBlueprint {
  id: number;
  name: string;
  sector: string;
  objective: string;
  kaijuId: string;
  kaijuName: string;
  category: number;
  threat: number;
  kaijuIntegrity: number;
  kaijuAttackInterval: number;
  kaijuDamage: number;
  cityPressure: number;
  civilianCount: number;
  seed: number;
  directorNote: string;
}

const clamp = (value: number, min: number, max: number) => Math.max(min, Math.min(max, value));

/**
 * Local tactical director: creates reproducible, bounded mission variants from
 * campaign state. It is deterministic game logic, not a remote generative model.
 * All combat values are clamped so the director cannot create impossible levels.
 */
export class MissionDirector {
  constructor(private readonly systems: TitanesSystems) {}

  generate(missionId = this.systems.snapshot().unlockedMissions): MissionBlueprint {
    const save = this.systems.snapshot();
    const mission = MISSION_LIST.find(item => item.id === missionId) ?? MISSION_LIST[0];
    const progress = this.systems.campaignProgress();
    const defense = this.systems.getBaseDefenseProfile();
    const jaeger = this.systems.getJaegerCombatStats();
    const failures = save.failedMissions.filter(id => id === missionId).length;
    const seed = missionId * 7919 + progress.completed * 1049 + save.xp * 17 + defense.rating * 31;
    const categoryByMission = [3, 2, 3, 4, 2, 3, 4, 5, 3, 4, 5, 5];
    const category = categoryByMission[missionId - 1] ?? 5;
    const archetype = KAIJU_ARCHETYPES[category - 1] ?? KAIJU_ARCHETYPES[0];
    const experienceFactor = progress.completed * 0.035;
    const pressureFactor = Math.max(0.78, 1 + experienceFactor - failures * 0.08);
    const playerReadiness = jaeger.armor + jaeger.power + jaeger.agility;
    const readinessFactor = clamp(1 + (playerReadiness - 190) / 900, 0.88, 1.12);
    const threat = clamp(category * 16 + missionId * 1.4, 18, 92);
    const integrity = Math.round(clamp((82 + missionId * 9 + category * 7) * pressureFactor * readinessFactor, 75, 220));
    const attackInterval = clamp(2.7 - category * 0.16 - missionId * 0.025 + failures * 0.12, 1.35, 2.8);
    const kaijuDamage = Math.round(clamp((7 + category * 1.8 + missionId * 0.35) * pressureFactor * readinessFactor, 6, 22));
    const cityPressure = Math.round(clamp(5 + category + missionId * 0.35, 4, 11));
    const civilianCount = clamp(4 + (missionId % 3) * 2 + Math.floor(defense.civilianProtection / 30), 4, 10);
    const objectives = [
      'Neutraliza la amenaza y protege el sector urbano.',
      'Mantén el perímetro y evita que el Kaiju alcance la zona civil.',
      'Rescata habitantes y reduce la presión sobre la ciudad.',
      'Defiende la infraestructura y completa el despliegue.'
    ];
    const objective = objectives[(missionId - 1) % objectives.length];
    const directorNote = failures > 0
      ? 'El director reduce ligeramente la presión tras una operación fallida; la amenaza sigue siendo peligrosa.'
      : playerReadiness < 170
        ? 'El director detecta una unidad de nivel inicial y mantiene la amenaza dentro de un margen de aprendizaje.'
        : 'El director adapta la amenaza al progreso, las mejoras y la defensa de la base.';
    return {
      id: missionId, name: mission.name, sector: mission.sector, objective,
      kaijuId: archetype.id, kaijuName: archetype.name, category,
      threat, kaijuIntegrity: integrity, kaijuAttackInterval: attackInterval,
      kaijuDamage, cityPressure, civilianCount, seed, directorNote
    };
  }
}
