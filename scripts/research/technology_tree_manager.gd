extends Node
class_name TechnologyTreeManager

signal technology_unlocked(technology_id: String)

const TECHNOLOGY_ORDER := [
	"survey_arrays", "salvage_protocols", "reactor_efficiency",
	"reinforced_frame", "resonance_training", "emergency_maintenance",
	"threat_analysis", "adaptive_hydraulics", "sector_logistics"
]
const TECHNOLOGIES := {
	"survey_arrays": {"name": "Matriz de cartografía", "branch": "Exploración", "cost": 12, "requires": [], "description": "+12 m al radio de reconocimiento."},
	"salvage_protocols": {"name": "Protocolos de recuperación", "branch": "Logística", "cost": 15, "requires": [], "description": "+150 de capacidad de almacén."},
	"reactor_efficiency": {"name": "Reactor de ciclo estable", "branch": "Energía", "cost": 20, "requires": ["survey_arrays"], "description": "+20% a la producción de instalaciones."},
	"reinforced_frame": {"name": "Armazón reforzado", "branch": "Ingeniería", "cost": 24, "requires": ["salvage_protocols"], "description": "Reduce un 8% los costes de reparación."},
	"resonance_training": {"name": "Entrenamiento de resonancia", "branch": "Pilotos", "cost": 28, "requires": ["reactor_efficiency"], "description": "+8% a la movilidad del Centinela."},
	"emergency_maintenance": {"name": "Mantenimiento de campaña", "branch": "Ingeniería", "cost": 32, "requires": ["reinforced_frame"], "description": "Reduce otro 7% los costes de reparación."},
	"threat_analysis": {"name": "Análisis de amenazas", "branch": "Exploración", "cost": 36, "requires": ["survey_arrays"], "description": "Mejora la preparación en encuentros."},
	"adaptive_hydraulics": {"name": "Hidráulica adaptativa", "branch": "Pilotos", "cost": 40, "requires": ["resonance_training"], "description": "+12% adicional a la movilidad."},
	"sector_logistics": {"name": "Red logística regional", "branch": "Logística", "cost": 45, "requires": ["emergency_maintenance", "reactor_efficiency"], "description": "+250 de capacidad de almacén."}
}
var unlocked: Array[String] = []
var selected_index := 0

func get_selected_id() -> String:
	return str(TECHNOLOGY_ORDER[clampi(selected_index, 0, TECHNOLOGY_ORDER.size() - 1)])

func select_next() -> String:
	selected_index = (selected_index + 1) % TECHNOLOGY_ORDER.size()
	return get_selected_id()

func is_unlocked(technology_id: String) -> bool:
	return technology_id in unlocked

func can_research(technology_id: String, available_data: int) -> bool:
	if not TECHNOLOGIES.has(technology_id) or is_unlocked(technology_id):
		return false
	var definition: Dictionary = TECHNOLOGIES[technology_id]
	if available_data < int(definition["cost"]):
		return false
	for requirement in definition["requires"]:
		if not is_unlocked(str(requirement)):
			return false
	return true

func research_selected(available_data: int) -> int:
	var technology_id := get_selected_id()
	if not can_research(technology_id, available_data):
		return -1
	unlocked.append(technology_id)
	technology_unlocked.emit(technology_id)
	return int(TECHNOLOGIES[technology_id]["cost"])

func get_selected_text(available_data: int) -> String:
	var technology_id := get_selected_id()
	var definition: Dictionary = TECHNOLOGIES[technology_id]
	var requirements: Array = definition["requires"]
	var requirement_text := "Ninguno" if requirements.is_empty() else ", ".join(PackedStringArray(requirements))
	var state := "INVESTIGADA" if is_unlocked(technology_id) else "DISPONIBLE" if can_research(technology_id, available_data) else "BLOQUEADA / DATOS INSUFICIENTES"
	return "INVESTIGACIÓN [%s]\n%s | %s datos | %s\n%s\nRequisitos: %s" % [str(definition["branch"]), str(definition["name"]), str(definition["cost"]), state, str(definition["description"]), requirement_text]

func get_scouting_bonus() -> float:
	return 12.0 if is_unlocked("survey_arrays") else 0.0

func get_storage_bonus() -> int:
	var bonus := 0
	if is_unlocked("salvage_protocols"):
		bonus += 150
	if is_unlocked("sector_logistics"):
		bonus += 250
	return bonus

func get_repair_discount_bonus() -> float:
	var bonus := 0.0
	if is_unlocked("reinforced_frame"):
		bonus += 0.08
	if is_unlocked("emergency_maintenance"):
		bonus += 0.07
	return bonus

func get_production_multiplier() -> float:
	return 1.2 if is_unlocked("reactor_efficiency") else 1.0

func get_mobility_multiplier() -> float:
	var multiplier := 1.0
	if is_unlocked("resonance_training"):
		multiplier += 0.08
	if is_unlocked("adaptive_hydraulics"):
		multiplier += 0.12
	return multiplier

func get_combat_preparation_bonus() -> int:
	return 2 if is_unlocked("threat_analysis") else 0

func get_summary_text() -> String:
	var lines := PackedStringArray(["TECNOLOGÍAS INVESTIGADAS: %d/%d" % [unlocked.size(), TECHNOLOGY_ORDER.size()]])
	for technology_id in TECHNOLOGY_ORDER:
		var definition: Dictionary = TECHNOLOGIES[str(technology_id)]
		var marker := "✓" if is_unlocked(str(technology_id)) else "·"
		lines.append("%s %s" % [marker, str(definition["name"])])
	return "\n".join(lines)

func export_state() -> Dictionary:
	return {"unlocked": unlocked.duplicate(), "selected_index": selected_index}

func import_state(data: Dictionary) -> void:
	unlocked.clear()
	var saved: Variant = data.get("unlocked", [])
	if saved is Array:
		for technology_id in saved:
			var id := str(technology_id)
			if TECHNOLOGIES.has(id) and id not in unlocked:
				unlocked.append(id)
	selected_index = clampi(int(data.get("selected_index", 0)), 0, TECHNOLOGY_ORDER.size() - 1)
