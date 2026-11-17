extends Resource
class_name MissionData
@export var mission_id: String = "first_expedition"
@export var title: String = "Primera expedición"
@export_multiline var description: String = "Recolecta materiales cerca de la base."
@export var target_resource: String = "metal"
@export var target_amount: int = 5
@export var reward: Dictionary = {"energy": 5}
