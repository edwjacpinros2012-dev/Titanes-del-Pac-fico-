extends Resource
class_name RecipeData

@export var recipe_id: String = "alloy_plate"
@export var display_name: String = "Placa de aleación"
@export_multiline var description: String = "Material procesado para módulos de la base."
@export var ingredients: Dictionary = {"metal": 3, "energy": 1}
@export var outputs: Dictionary = {"alloy_plate": 1}
@export var required_research: String = ""
@export_range(0.0, 3600.0, 0.5) var crafting_seconds: float = 2.0
