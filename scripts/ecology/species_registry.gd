extends Node
class_name SpeciesRegistry

## Catalogo y registro de observaciones de fauna para exploracion y misiones.
## Es una capa de datos independiente: la escena/UI puede conectarla mediante senales.

signal species_registered(species_id: String, region_id: String)
signal observation_progress(species_id: String, total: int, next_milestone: int)
signal research_data_awarded(species_id: String, amount: int)
signal registry_changed

const SPECIES := {
	"lumina_ray": {
		"name": "Raya luminosa",
		"region": "aurora_coast",
		"habitat": "Aguas costeras poco profundas",
		"behavior": "Se desplaza en grupos y evita zonas ruidosas",
		"milestones": [1, 3, 5],
		"rewards": [2, 3, 5]
	},
	"basalt_grazer": {
		"name": "Herbivoro de basalto",
		"region": "broken_isles",
		"habitat": "Laderas volcanicas",
		"behavior": "Busca minerales expuestos y cambia de ruta con el clima",
		"milestones": [1, 3, 5],
		"rewards": [2, 3, 5]
	},
	"trench_glider": {
		"name": "Planeador abisal",
		"region": "deep_trench",
		"habitat": "Borde de la fosa",
		"behavior": "Aparece cerca de corrientes profundas",
		"milestones": [1, 3, 5],
		"rewards": [3, 4, 6]
	}
}

var observations: Dictionary = {}
var registered_species: Array[String] = []
var claimed_milestones: Dictionary = {}

func observe(species_id: String, region_id: String) -> bool:
	if not SPECIES.has(species_id):
		return false
	var species: Dictionary = SPECIES[species_id]
	if str(species.get("region", "")) != region_id:
		return false
	var count := int(observations.get(species_id, 0)) + 1
	observations[species_id] = count
	if species_id not in registered_species:
		registered_species.append(species_id)
		species_registered.emit(species_id, region_id)
	var milestones: Array = species.get("milestones", [])
	var rewards: Array = species.get("rewards", [])
	var claimed: Array = claimed_milestones.get(species_id, [])
	for i in range(mini(milestones.size(), rewards.size())):
		var milestone := int(milestones[i])
		if count >= milestone and milestone not in claimed:
			claimed.append(milestone)
			research_data_awarded.emit(species_id, int(rewards[i]))
	claimed_milestones[species_id] = claimed
	var next_milestone := 0
	for milestone in milestones:
		if count < int(milestone):
			next_milestone = int(milestone)
			break
	observation_progress.emit(species_id, count, next_milestone)
	registry_changed.emit()
	return true

func get_species_info(species_id: String) -> Dictionary:
	if not SPECIES.has(species_id):
		return {}
	return SPECIES[species_id].duplicate(true)

func get_observation_count(species_id: String) -> int:
	return int(observations.get(species_id, 0))

func get_completion(species_id: String) -> float:
	if not SPECIES.has(species_id):
		return 0.0
	var milestones: Array = SPECIES[species_id].get("milestones", [])
	if milestones.is_empty():
		return 0.0
	return clampf(float(get_observation_count(species_id)) / float(milestones.back()), 0.0, 1.0)

func export_snapshot() -> Dictionary:
	return {
		"observations": observations.duplicate(true),
		"registered_species": registered_species.duplicate(),
		"claimed_milestones": claimed_milestones.duplicate(true)
	}

func import_snapshot(snapshot: Dictionary) -> bool:
	var incoming: Variant = snapshot.get("observations", {})
	if typeof(incoming) != TYPE_DICTIONARY:
		return false
	var clean_observations := {}
	for species_id in incoming:
		if not SPECIES.has(str(species_id)) or int(incoming[species_id]) < 0:
			return false
		clean_observations[str(species_id)] = int(incoming[species_id])
	var incoming_registered: Variant = snapshot.get("registered_species", [])
	if typeof(incoming_registered) != TYPE_ARRAY:
		return false
	var clean_registered: Array[String] = []
	for species_id in incoming_registered:
		if SPECIES.has(str(species_id)) and str(species_id) not in clean_registered:
			clean_registered.append(str(species_id))
	var incoming_claimed: Variant = snapshot.get("claimed_milestones", {})
	if typeof(incoming_claimed) != TYPE_DICTIONARY:
		return false
	var clean_claimed := {}
	for species_id in incoming_claimed:
		if not SPECIES.has(str(species_id)) or typeof(incoming_claimed[species_id]) != TYPE_ARRAY:
			return false
		var allowed_milestones: Array = SPECIES[str(species_id)].get("milestones", [])
		var valid_claims: Array = []
		for milestone_value in incoming_claimed[species_id]:
			var milestone := int(milestone_value)
			if milestone not in allowed_milestones or milestone > int(clean_observations.get(str(species_id), 0)):
				return false
			if milestone not in valid_claims:
				valid_claims.append(milestone)
		clean_claimed[str(species_id)] = valid_claims
	observations = clean_observations
	registered_species = clean_registered
	claimed_milestones = clean_claimed
	registry_changed.emit()
	return true
