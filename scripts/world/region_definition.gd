extends Resource
class_name RegionDefinition

@export var region_id: String = "aurora_coast"
@export var display_name: String = "Costa de la Aurora"
@export_multiline var description: String = "Una costa tranquila donde comienza la expedición."
@export var required_research: String = ""
@export var resource_ids: Array[String] = ["metal", "energy"]
@export_range(1, 5, 1) var exploration_rank: int = 1
@export var weather_profile: String = "coastal"
