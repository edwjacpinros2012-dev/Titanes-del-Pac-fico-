extends Node
class_name RegionManager
signal region_unlocked(region_id: String)
signal region_changed(region_id: String)
var unlocked_regions: Array[String] = ["aurora_coast"]
var current_region := "aurora_coast"
func is_unlocked(region_id: String) -> bool:
	return region_id in unlocked_regions
func unlock_region(region_id: String) -> void:
	if region_id in unlocked_regions: return
	unlocked_regions.append(region_id)
	region_unlocked.emit(region_id)
func travel_to(region_id: String) -> bool:
	if not is_unlocked(region_id): return false
	current_region = region_id
	region_changed.emit(region_id)
	return true
