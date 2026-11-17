extends Node
class_name BaseDevelopmentManager

signal facility_upgraded(facility_id: String, new_level: int)
signal production_generated(resource_id: String, amount: int)
signal research_generated(amount: int)

const PRODUCTION_INTERVAL := 60.0
const FACILITY_ORDER := [
	"command_hub", "hangar", "reactor", "refinery", "laboratory",
	"warehouse", "radar", "airfield", "alliance_hall", "repair_bay"
]

const FACILITIES := {
	"command_hub": {
		"name": "Centro de mando", "max_level": 5, "unlock_level": 1,
		"cost": {"metal": 8, "energia": 4, "cristal": 0},
		"prerequisites": {}, "output": "", "rate": 0,
		"description": "Amplía el nivel máximo de desarrollo de toda la base."
	},
	"hangar": {
		"name": "Hangar de Centinelas", "max_level": 5, "unlock_level": 1,
		"cost": {"metal": 14, "energia": 6, "cristal": 1},
		"prerequisites": {}, "output": "", "rate": 0,
		"description": "Desbloquea mejoras de mantenimiento y preparación de Centinelas."
	},
	"reactor": {
		"name": "Núcleo energético", "max_level": 5, "unlock_level": 1,
		"cost": {"metal": 12, "energia": 0, "cristal": 2},
		"prerequisites": {}, "output": "energia", "rate": 2,
		"description": "Produce energía de base cada minuto."
	},
	"refinery": {
		"name": "Refinería", "max_level": 5, "unlock_level": 2,
		"cost": {"metal": 20, "energia": 10, "cristal": 2},
		"prerequisites": {"command_hub": 2}, "output": "metal", "rate": 1,
		"description": "Recupera metal de los materiales recogidos."
	},
	"laboratory": {
		"name": "Laboratorio", "max_level": 5, "unlock_level": 2,
		"cost": {"metal": 16, "energia": 12, "cristal": 5},
		"prerequisites": {"hangar": 2}, "output": "research_data", "rate": 1,
		"description": "Prepara investigación y futuras tecnologías."
	},
	"warehouse": {
		"name": "Almacén central", "max_level": 5, "unlock_level": 2,
		"cost": {"metal": 18, "energia": 8, "cristal": 1},
		"prerequisites": {}, "output": "", "rate": 0,
		"description": "Aumenta la capacidad de almacenamiento de recursos."
	},
	"radar": {
		"name": "Torre de reconocimiento", "max_level": 5, "unlock_level": 3,
		"cost": {"metal": 22, "energia": 14, "cristal": 4},
		"prerequisites": {"laboratory": 1}, "output": "", "rate": 0,
		"description": "Mejora la detección y el análisis de amenazas."
	},
	"airfield": {
		"name": "Puerto aéreo", "max_level": 5, "unlock_level": 3,
		"cost": {"metal": 26, "energia": 16, "cristal": 3},
		"prerequisites": {"hangar": 2}, "output": "", "rate": 0,
		"description": "Amplía las operaciones de reconocimiento aéreo."
	},
	"alliance_hall": {
		"name": "Centro de alianzas", "max_level": 5, "unlock_level": 4,
		"cost": {"metal": 30, "energia": 18, "cristal": 6},
		"prerequisites": {"radar": 2}, "output": "", "rate": 0,
		"description": "Prepara instalaciones para cooperación entre pactos."
	},
	"repair_bay": {
		"name": "Taller de reparación", "max_level": 5, "unlock_level": 2,
		"cost": {"metal": 20, "energia": 10, "cristal": 2},
		"prerequisites": {"hangar": 1}, "output": "", "rate": 0,
		"description": "Prepara el mantenimiento después de retiradas y derrotas."
	}
}

var facility_levels: Dictionary = {
	"command_hub": 1,
	"hangar": 1,
	"reactor": 1
}
var selected_index := 1
var production_seconds := 0.0
var total_production_cycles := 0

func get_facility_level(facility_id: String) -> int:
	return int(facility_levels.get(facility_id, 0))

func get_facility_name(facility_id: String) -> String:
	var definition: Dictionary = FACILITIES.get(facility_id, {})
	return str(definition.get("name", "Instalación desconocida"))

func get_selected_facility_id() -> String:
	return str(FACILITY_ORDER[clampi(selected_index, 0, FACILITY_ORDER.size() - 1)])

func get_upgrade_cost(facility_id: String) -> Dictionary:
	var definition: Dictionary = FACILITIES.get(facility_id, {})
	if definition.is_empty():
		return {}
	var level := get_facility_level(facility_id)
	var base_cost: Dictionary = definition.get("cost", {})
	var result: Dictionary = {}
	for resource_id in base_cost:
		result[resource_id] = int(base_cost[resource_id]) * maxi(1, level)
	return result

func can_upgrade(facility_id: String, inventory: Dictionary, base_level: int) -> bool:
	var definition: Dictionary = FACILITIES.get(facility_id, {})
	if definition.is_empty():
		return false
	var current_level := get_facility_level(facility_id)
	if current_level >= int(definition.get("max_level", 1)):
		return false
	if base_level < int(definition.get("unlock_level", 1)):
		return false
	var prerequisites: Dictionary = definition.get("prerequisites", {})
	for prerequisite_id in prerequisites:
		if get_facility_level(str(prerequisite_id)) < int(prerequisites[prerequisite_id]):
			return false
	var cost := get_upgrade_cost(facility_id)
	for resource_id in cost:
		if int(inventory.get(resource_id, 0)) < int(cost[resource_id]):
			return false
	return true

func upgrade_facility(facility_id: String, inventory: Dictionary, base_level: int) -> bool:
	if not can_upgrade(facility_id, inventory, base_level):
		return false
	var cost := get_upgrade_cost(facility_id)
	for resource_id in cost:
		inventory[resource_id] = int(inventory.get(resource_id, 0)) - int(cost[resource_id])
	var new_level := get_facility_level(facility_id) + 1
	facility_levels[facility_id] = new_level
	facility_upgraded.emit(facility_id, new_level)
	return true

func select_next_facility(base_level: int) -> String:
	for offset in range(1, FACILITY_ORDER.size() + 1):
		var candidate_index := (selected_index + offset) % FACILITY_ORDER.size()
		var candidate_id := str(FACILITY_ORDER[candidate_index])
		var definition: Dictionary = FACILITIES[candidate_id]
		if base_level >= int(definition.get("unlock_level", 1)):
			selected_index = candidate_index
			return candidate_id
	return get_selected_facility_id()

func advance_production(delta: float, inventory: Dictionary) -> int:
	production_seconds += maxf(0.0, delta)
	var generated_total := 0
	while production_seconds >= PRODUCTION_INTERVAL:
		production_seconds -= PRODUCTION_INTERVAL
		total_production_cycles += 1
		for facility_id in FACILITY_ORDER:
			var definition: Dictionary = FACILITIES[str(facility_id)]
			var resource_id := str(definition.get("output", ""))
			var rate := int(definition.get("rate", 0))
			var level := get_facility_level(str(facility_id))
			if resource_id.is_empty() or rate <= 0 or level <= 0:
				continue
			var amount := rate * level
			if resource_id == "research_data":
				research_generated.emit(amount)
				generated_total += amount
				continue
			var capacity := get_storage_capacity()
			var current_amount := int(inventory.get(resource_id, 0))
			var actual_amount := mini(amount, maxi(0, capacity - current_amount))
			if actual_amount <= 0:
				continue
			inventory[resource_id] = current_amount + actual_amount
			generated_total += actual_amount
			production_generated.emit(resource_id, actual_amount)
	return generated_total

func get_selected_facility_text(inventory: Dictionary, base_level: int) -> String:
	var facility_id := get_selected_facility_id()
	var definition: Dictionary = FACILITIES[facility_id]
	var level := get_facility_level(facility_id)
	var cost := get_upgrade_cost(facility_id)
	var cost_text := " | Coste: %d metal, %d energía, %d cristal" % [
		int(cost.get("metal", 0)), int(cost.get("energia", 0)), int(cost.get("cristal", 0))
	]
	var can_build_or_upgrade := can_upgrade(facility_id, inventory, base_level)
	var status := "CONSTRUIBLE" if level == 0 and can_build_or_upgrade else "MEJORABLE" if can_build_or_upgrade else "BLOQUEADA O FALTAN RECURSOS"
	if level >= int(definition.get("max_level", 1)):
		status = "NIVEL MÁXIMO"
	return "%s | Nivel %d/%d | %s%s" % [
		str(definition["name"]), level, int(definition["max_level"]), status, cost_text
	]


func get_storage_capacity() -> int:
	return 250 + get_facility_level("warehouse") * 250

func get_repair_discount() -> float:
	var hangar_bonus := float(get_facility_level("hangar")) * 0.04
	var repair_bonus := float(get_facility_level("repair_bay")) * 0.10
	return clampf(hangar_bonus + repair_bonus, 0.0, 0.60)

func get_scouting_radius(base_radius: float = 30.0) -> float:
	return base_radius + float(get_facility_level("radar")) * 8.0 + float(get_facility_level("airfield")) * 4.0

func get_facility_effects_text() -> String:
	return "Almacén: %d por recurso | Descuento reparación: %d%% | Radio de reconocimiento: %d m" % [
		get_storage_capacity(), roundi(get_repair_discount() * 100.0), roundi(get_scouting_radius())
	]

func get_status_text() -> String:
	var lines := PackedStringArray(["INSTALACIONES DE LA BASE", get_facility_effects_text()])
	for facility_id in FACILITY_ORDER:
		var definition: Dictionary = FACILITIES[str(facility_id)]
		var level := get_facility_level(str(facility_id))
		if level > 0:
			lines.append("%s Nv.%d" % [str(definition["name"]), level])
	return "\n".join(lines)

func export_state() -> Dictionary:
	return {
		"facility_levels": facility_levels.duplicate(true),
		"selected_index": selected_index,
		"production_seconds": production_seconds,
		"total_production_cycles": total_production_cycles
	}

func import_state(data: Dictionary) -> void:
	var saved_levels: Variant = data.get("facility_levels", {})
	if typeof(saved_levels) == TYPE_DICTIONARY:
		for facility_id in FACILITY_ORDER:
			var id := str(facility_id)
			if saved_levels.has(id):
				var definition: Dictionary = FACILITIES[id]
				facility_levels[id] = clampi(int(saved_levels[id]), 0, int(definition["max_level"]))
	selected_index = clampi(int(data.get("selected_index", selected_index)), 0, FACILITY_ORDER.size() - 1)
	production_seconds = clampf(float(data.get("production_seconds", 0.0)), 0.0, PRODUCTION_INTERVAL)
	total_production_cycles = maxi(0, int(data.get("total_production_cycles", 0)))
	if get_facility_level("command_hub") < 1:
		facility_levels["command_hub"] = 1

func set_legacy_base_level(level: int) -> void:
	facility_levels["command_hub"] = clampi(level, 1, int(FACILITIES["command_hub"]["max_level"]))
