extends Node
class_name HangarState

const HANGAR_SCENE := "res://scenes/hangar.tscn"
const MISSION_SCENE := "res://scenes/missions/coastal_operation.tscn"

var selected_jaeger_id := "titan_alpha"

func select_jaeger(jaeger_id: String) -> bool:
	if jaeger_id != "titan_alpha":
		return false
	selected_jaeger_id = jaeger_id
	return true

func deploy_selected_jaeger() -> bool:
	if selected_jaeger_id != "titan_alpha":
		return false
	return get_tree().change_scene_to_file(MISSION_SCENE) == OK

func return_to_hangar() -> bool:
	return get_tree().change_scene_to_file(HANGAR_SCENE) == OK
