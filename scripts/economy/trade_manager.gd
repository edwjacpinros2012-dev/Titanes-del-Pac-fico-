extends Node
class_name TradeManager

signal credits_changed(total: int)
signal trade_completed(good_id: String, direction: String, quantity: int)

const STATE_VERSION := 1
const MAX_STOCK := 1000000

var credits: int = 250
var last_message: String = "Mercado costero disponible."
var buy_prices: Dictionary = {"metal": 12, "energia": 18, "cristal": 28}
var sell_prices: Dictionary = {"metal": 7, "energia": 11, "cristal": 19}
var market_stock: Dictionary = {"metal": 40, "energia": 25, "cristal": 12}

func buy_good(good_id: String, quantity: int, inventory: Dictionary) -> bool:
	if not buy_prices.has(good_id) or quantity <= 0:
		last_message = "Producto no disponible."
		return false
	var total_cost := int(buy_prices[good_id]) * quantity
	if int(market_stock.get(good_id, 0)) < quantity:
		last_message = "El mercado no tiene suficiente existencias."
		return false
	if credits < total_cost:
		last_message = "No tienes suficientes créditos."
		return false
	credits -= total_cost
	market_stock[good_id] = int(market_stock[good_id]) - quantity
	inventory[good_id] = int(inventory.get(good_id, 0)) + quantity
	last_message = "Compraste %d de %s por %d créditos." % [quantity, good_id, total_cost]
	credits_changed.emit(credits)
	trade_completed.emit(good_id, "buy", quantity)
	return true

func sell_good(good_id: String, quantity: int, inventory: Dictionary) -> bool:
	if not sell_prices.has(good_id) or quantity <= 0:
		last_message = "Producto no aceptado."
		return false
	if int(inventory.get(good_id, 0)) < quantity:
		last_message = "No tienes suficientes unidades para vender."
		return false
	inventory[good_id] = int(inventory[good_id]) - quantity
	market_stock[good_id] = mini(MAX_STOCK, int(market_stock.get(good_id, 0)) + quantity)
	var payment := int(sell_prices[good_id]) * quantity
	credits += payment
	last_message = "Vendiste %d de %s y recibiste %d créditos." % [quantity, good_id, payment]
	credits_changed.emit(credits)
	trade_completed.emit(good_id, "sell", quantity)
	return true

func add_credits(amount: int) -> void:
	if amount <= 0:
		return
	credits += amount
	credits_changed.emit(credits)

func export_state() -> Dictionary:
	return {
		"version": STATE_VERSION,
		"credits": maxi(0, credits),
		"market_stock": market_stock.duplicate(true)
	}

func import_state(data: Dictionary) -> void:
	credits = maxi(0, int(data.get("credits", credits)))
	var saved_stock: Variant = data.get("market_stock", {})
	if saved_stock is Dictionary:
		for good_id in buy_prices:
			if saved_stock.has(good_id):
				market_stock[good_id] = clampi(int(saved_stock[good_id]), 0, MAX_STOCK)
	credits_changed.emit(credits)

func get_market_text() -> String:
	return "MERCADO COSTERO | Créditos: %d\\n1 Comprar 3 metal (%d c) | 2 Comprar 3 energía (%d c) | 3 Comprar 2 cristal (%d c)\\n4 Vender 3 metal (%d c) | 5 Vender 3 energía (%d c) | 6 Vender 2 cristal (%d c)\\nC: cerrar mercado" % [
		credits,
		int(buy_prices["metal"]) * 3,
		int(buy_prices["energia"]) * 3,
		int(buy_prices["cristal"]) * 2,
		int(sell_prices["metal"]) * 3,
		int(sell_prices["energia"]) * 3,
		int(sell_prices["cristal"]) * 2
	]
