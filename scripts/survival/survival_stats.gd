extends Node
class_name SurvivalStats

signal stamina_changed(value: float)
signal suit_charge_changed(value: float)

@export var max_stamina := 100.0
@export var stamina_recovery := 14.0
@export var max_suit_charge := 100.0
@export var suit_recovery := 2.0
var stamina := 100.0
var suit_charge := 100.0

func _process(delta: float) -> void:
	var old_stamina := stamina
	var old_charge := suit_charge
	stamina = minf(max_stamina, stamina + stamina_recovery * delta)
	suit_charge = minf(max_suit_charge, suit_charge + suit_recovery * delta)
	if not is_equal_approx(old_stamina, stamina):
		stamina_changed.emit(stamina)
	if not is_equal_approx(old_charge, suit_charge):
		suit_charge_changed.emit(suit_charge)

func spend_stamina(amount: float) -> bool:
	if amount <= 0.0 or stamina < amount:
		return false
	stamina -= amount
	stamina_changed.emit(stamina)
	return true

func spend_suit_charge(amount: float) -> bool:
	if amount <= 0.0 or suit_charge < amount:
		return false
	suit_charge -= amount
	suit_charge_changed.emit(suit_charge)
	return true
