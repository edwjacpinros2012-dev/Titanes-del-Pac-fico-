extends Node
class_name CraftingManager

signal crafting_started(recipe_id: String)
signal crafting_completed(recipe_id: String, outputs: Dictionary)
signal crafting_failed(reason: String)

var recipes: Dictionary = {}

func register_recipe(recipe: RecipeData) -> void:
	if recipe == null or recipe.recipe_id.is_empty():
		return
	recipes[recipe.recipe_id] = recipe

func craft(recipe_id: String, inventory: Inventory, unlocked_research: Array[String] = []) -> bool:
	if not recipes.has(recipe_id):
		crafting_failed.emit("No existe esa receta.")
		return false
	if inventory == null:
		crafting_failed.emit("No hay inventario disponible.")
		return false
	var recipe: RecipeData = recipes[recipe_id]
	if not recipe.required_research.is_empty() and recipe.required_research not in unlocked_research:
		crafting_failed.emit("Primero debes desbloquear la investigación requerida.")
		return false
	if not inventory.remove_items(recipe.ingredients):
		crafting_failed.emit("No tienes suficientes materiales.")
		return false
	crafting_started.emit(recipe_id)
	if recipe.crafting_seconds > 0.0:
		await get_tree().create_timer(recipe.crafting_seconds).timeout
	for item_id in recipe.outputs:
		inventory.add_item(str(item_id), int(recipe.outputs[item_id]))
	crafting_completed.emit(recipe_id, recipe.outputs)
	return true
