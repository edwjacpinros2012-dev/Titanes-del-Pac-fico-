extends Node
class_name RegionRestorationManager

signal progress_changed(region_id: String, snapshot: Dictionary)
signal milestone_unlocked(region_id: String, milestone_id: String, threshold: int)

const REGION_DATA := {
	"aurora_coast": {"name": "Costa Aurora", "description": "Zona costera inicial"},
	"broken_isles": {"name": "Islas Quebradas", "description": "Archipiélago de exploración"},
	"volcanic_belt": {"name": "Cinturón Volcánico", "description": "Región avanzada"}
}
const CATEGORIES := ["exploration", "ecology", "infrastructure", "research"]
const MILESTONES := [
	{"id": "surveyed", "threshold": 20, "title": "Sector cartografiado"},
	{"id": "supported", "threshold": 50, "title": "Infraestructura de apoyo"},
	{"id": "renewed", "threshold": 80, "title": "Ecosistema recuperándose"},
	{"id": "thriving", "threshold": 100, "title": "Región estabilizada"}
]
const MAX_PROGRESS := 100

var active_region_id := "aurora_coast"
var regions: Dictionary = {}

func _ready() -> void:
	for region_id in REGION_DATA:
		if not regions.has(region_id):
			regions[region_id] = _new_region()

func _new_region() -> Dictionary:
	var category_progress := {}
	for category in CATEGORIES:
		category_progress[category] = 0
	return {"progress": 0, "categories": category_progress, "milestones": []}

func set_active_region(region_id: String) -> bool:
	if not REGION_DATA.has(region_id):
		return false
	active_region_id = region_id
	if not regions.has(region_id):
		regions[region_id] = _new_region()
	return true

func add_progress(amount: int, category: String, region_id: String = "") -> int:
	if amount <= 0 or not CATEGORIES.has(category):
		return 0
	var target_id := active_region_id if region_id.is_empty() else region_id
	if not REGION_DATA.has(target_id):
		return 0
	if not regions.has(target_id):
		regions[target_id] = _new_region()
	var state: Dictionary = regions[target_id]
	var old_progress := int(state.get("progress", 0))
	var new_progress := mini(MAX_PROGRESS, old_progress + amount)
	var gained := new_progress - old_progress
	if gained <= 0:
		return 0
	state["progress"] = new_progress
	var category_values: Dictionary = state.get("categories", {})
	category_values[category] = mini(MAX_PROGRESS, int(category_values.get(category, 0)) + gained)
	state["categories"] = category_values
	var claimed: Array = state.get("milestones", [])
	for milestone in MILESTONES:
		var milestone_id: String = milestone["id"]
		var threshold := int(milestone["threshold"])
		if new_progress >= threshold and milestone_id not in claimed:
			claimed.append(milestone_id)
			milestone_unlocked.emit(target_id, milestone_id, threshold)
	state["milestones"] = claimed
	regions[target_id] = state
	progress_changed.emit(target_id, get_region_snapshot(target_id))
	return gained

func get_region_snapshot(region_id: String = "") -> Dictionary:
	var target_id := active_region_id if region_id.is_empty() else region_id
	if not REGION_DATA.has(target_id):
		return {}
	var state: Dictionary = regions.get(target_id, _new_region())
	return {
		"region_id": target_id,
		"name": REGION_DATA[target_id]["name"],
		"progress": int(state.get("progress", 0)),
		"categories": (state.get("categories", {}) as Dictionary).duplicate(true),
		"milestones": (state.get("milestones", []) as Array).duplicate(true),
		"stage": get_stage(int(state.get("progress", 0)))
	}

func get_stage(progress: int) -> String:
	if progress >= 100:
		return "Estabilizada"
	if progress >= 80:
		return "Recuperándose"
	if progress >= 50:
		return "Infraestructura"
	if progress >= 20:
		return "Cartografiada"
	return "Sin explorar"

func export_state() -> Dictionary:
	return {"version": 1, "active_region_id": active_region_id, "regions": regions.duplicate(true)}

func import_state(snapshot: Dictionary) -> bool:
	if int(snapshot.get("version", 0)) != 1:
		return false
	var loaded_active := str(snapshot.get("active_region_id", "aurora_coast"))
	if not REGION_DATA.has(loaded_active):
		return false
	var loaded_regions: Variant = snapshot.get("regions", {})
	if typeof(loaded_regions) != TYPE_DICTIONARY:
		return false
	var validated := {}
	for region_id in loaded_regions:
		if not REGION_DATA.has(str(region_id)):
			return false
		var entry: Variant = loaded_regions[region_id]
		if typeof(entry) != TYPE_DICTIONARY:
			return false
		var progress := int(entry.get("progress", -1))
		if progress < 0 or progress > MAX_PROGRESS:
			return false
		var categories: Variant = entry.get("categories", {})
		var milestones: Variant = entry.get("milestones", [])
		if typeof(categories) != TYPE_DICTIONARY or typeof(milestones) != TYPE_ARRAY:
			return false
		var normalized := _new_region()
		normalized["progress"] = progress
		for category in CATEGORIES:
			var value := int(categories.get(category, 0))
			if value < 0 or value > MAX_PROGRESS:
				return false
			normalized["categories"][category] = value
		var category_total := 0
		for category in CATEGORIES:
			category_total += int(normalized["categories"][category])
		if category_total != progress:
			return false
		for milestone_id in milestones:
			var matched_milestone := {}
			for milestone in MILESTONES:
				if milestone["id"] == str(milestone_id):
					matched_milestone = milestone
					break
			if matched_milestone.is_empty() or progress < int(matched_milestone["threshold"]):
				return false
			if str(milestone_id) not in normalized["milestones"]:
				normalized["milestones"].append(str(milestone_id))
		validated[str(region_id)] = normalized
	for region_id in REGION_DATA:
		if not validated.has(region_id):
			validated[region_id] = _new_region()
	regions = validated
	active_region_id = loaded_active
	return true
