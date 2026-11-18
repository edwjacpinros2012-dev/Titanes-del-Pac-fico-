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
	var recipe := _get_valid_recipe(recipe_id, inventory, unlocked_research)
	if recipe == null:
		return false
	if recipe.crafting_seconds > 0.0:
		crafting_failed.emit("Esta receta requiere tiempo de fabricación; utiliza craft_async().")
		return false
	if not inventory.remove_items(recipe.ingredients):
		crafting_failed.emit("No tienes suficientes materiales.")
		return false
	crafting_started.emit(recipe_id)
	_grant_outputs(recipe, inventory)
	return true

func craft_async(recipe_id: String, inventory: Inventory, unlocked_research: Array[String] = []) -> bool:
	var recipe := _get_valid_recipe(recipe_id, inventory, unlocked_research)
	if recipe == null:
		return false
	if not inventory.remove_items(recipe.ingredients):
		crafting_failed.emit("No tienes suficientes materiales.")
		return false
	crafting_started.emit(recipe_id)
	if recipe.crafting_seconds > 0.0:
		await get_tree().create_timer(recipe.crafting_seconds).timeout
	_grant_outputs(recipe, inventory)
	return true

func _get_valid_recipe(recipe_id: String, inventory: Inventory, unlocked_research: Array[String]) -> RecipeData:
	if not recipes.has(recipe_id):
		crafting_failed.emit("No existe esa receta.")
		return null
	if inventory == null:
		crafting_failed.emit("No hay inventario disponible.")
		return null
	var recipe: RecipeData = recipes[recipe_id]
	if not recipe.required_research.is_empty() and recipe.required_research not in unlocked_research:
		crafting_failed.emit("Primero debes desbloquear la investigación requerida.")
		return null
	if not inventory.has_items(recipe.ingredients):
		crafting_failed.emit("No tienes suficientes materiales.")
		return null
	return recipe

func _grant_outputs(recipe: RecipeData, inventory: Inventory) -> void:
	for item_id in recipe.outputs:
		inventory.add_item(str(item_id), int(recipe.outputs[item_id]))
	crafting_completed.emit(recipe.recipe_id, recipe.outputs)
