export type WorldEventId =
  | 'storm_surge'
  | 'power_grid_failure'
  | 'civilian_evacuation'
  | 'supply_convoy'
  | 'seismic_warning'
  | 'harbor_blackout';

export interface WorldDirective {
  eventId: WorldEventId;
  eventTitle: string;
  briefing: string;
  district: string;
  weather: string;
  priority: 'routine' | 'elevated' | 'critical';
  cityPressureModifier: number;
  kaijuDamageModifier: number;
  civilianCountModifier: number;
  countermeasure: string;
}

const EVENTS: Omit<WorldDirective, 'district' | 'weather'>[] = [
  {
    eventId: 'storm_surge',
    eventTitle: 'MAREJADA EXTREMA',
    briefing: 'Una marejada avanza sobre el litoral y reduce las rutas seguras de evacuación.',
    priority: 'critical',
    cityPressureModifier: 2,
    kaijuDamageModifier: 1,
    civilianCountModifier: 1,
    countermeasure: 'Asegura el malecón y abre el corredor elevado de evacuación.'
  },
  {
    eventId: 'power_grid_failure',
    eventTitle: 'FALLO DE LA RED ELÉCTRICA',
    briefing: 'Un apagón parcial afecta sensores, iluminación y sistemas de apoyo urbano.',
    priority: 'elevated',
    cityPressureModifier: 1,
    kaijuDamageModifier: 0,
    civilianCountModifier: 0,
    countermeasure: 'Restablece el reactor auxiliar y protege el centro de distribución.'
  },
  {
    eventId: 'civilian_evacuation',
    eventTitle: 'ALERTA DE EVACUACIÓN',
    briefing: 'Se detectan grupos civiles en una zona de riesgo y se necesita apoyo inmediato.',
    priority: 'critical',
    cityPressureModifier: 0,
    kaijuDamageModifier: 0,
    civilianCountModifier: 2,
    countermeasure: 'Prioriza el rescate y mantén libre la ruta hacia el refugio.'
  },
  {
    eventId: 'supply_convoy',
    eventTitle: 'CONVOY DE SUMINISTROS',
    briefing: 'Un convoy aliado solicita escolta para entregar piezas y energía a la base.',
    priority: 'routine',
    cityPressureModifier: -1,
    kaijuDamageModifier: 0,
    civilianCountModifier: 0,
    countermeasure: 'Mantén despejada la ruta logística y protege el punto de entrega.'
  },
  {
    eventId: 'seismic_warning',
    eventTitle: 'ALERTA SÍSMICA',
    briefing: 'La actividad del subsuelo amenaza estructuras dañadas y túneles de servicio.',
    priority: 'elevated',
    cityPressureModifier: 1,
    kaijuDamageModifier: 1,
    civilianCountModifier: 1,
    countermeasure: 'Evita las zonas inestables y protege las instalaciones críticas.'
  },
  {
    eventId: 'harbor_blackout',
    eventTitle: 'PUERTO SIN VISIBILIDAD',
    briefing: 'La niebla y el fallo de balizas reducen la visibilidad en el sector portuario.',
    priority: 'elevated',
    cityPressureModifier: 1,
    kaijuDamageModifier: 0,
    civilianCountModifier: 1,
    countermeasure: 'Activa balizas de emergencia y vigila los accesos al puerto.'
  }
];

const DISTRICTS = [
  'PUERTO DE SHATTERDOME',
  'DISTRITO INDUSTRIAL',
  'BAHÍA DE CONTENCIÓN',
  'CENTRO COSTERO',
  'CORREDOR DE EVACUACIÓN',
  'ZONA DE REACTORES',
  'MUELLES EXTERIORES',
  'DISTRITO ANTIGUO'
];

const WEATHER = [
  'LLUVIA INTENSA',
  'NIEBLA COSTERA',
  'TORMENTA ELÉCTRICA',
  'CIELO NUBLADO',
  'VIENTO MARINO',
  'LLUVIA Y BRUMA'
];

function positiveIndex(value: number, length: number): number {
  return ((Math.trunc(value) % length) + length) % length;
}

/**
 * Deterministic local world controller. It produces bounded event modifiers
 * from campaign state; it does not call a remote model or alter save data.
 */
export function createWorldDirective(seed: number, missionId: number, defenseRating: number): WorldDirective {
  const safeSeed = Number.isFinite(seed) ? Math.trunc(seed) : 1;
  const eventIndex = positiveIndex(safeSeed + missionId * 17 + Math.max(0, defenseRating) * 3, EVENTS.length);
  const districtIndex = positiveIndex(safeSeed * 7 + missionId * 11, DISTRICTS.length);
  const weatherIndex = positiveIndex(safeSeed * 13 + missionId * 5, WEATHER.length);
  const event = EVENTS[eventIndex];

  return {
    ...event,
    district: DISTRICTS[districtIndex],
    weather: WEATHER[weatherIndex],
    cityPressureModifier: Math.max(-1, Math.min(2, event.cityPressureModifier)),
    kaijuDamageModifier: Math.max(0, Math.min(1, event.kaijuDamageModifier)),
    civilianCountModifier: Math.max(0, Math.min(2, event.civilianCountModifier))
  };
}
