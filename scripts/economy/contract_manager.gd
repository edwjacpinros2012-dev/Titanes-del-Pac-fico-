extends Node
class_name ContractManager

signal contract_completed(title: String, reward: Dictionary)
signal contracts_changed

var contracts: Array[Dictionary] = [
	{"id": "first_rift", "title": "Cartógrafo de brechas", "action": "rift", "target": 1, "progress": 0, "claimed": false, "reward": {"credits": 120, "research_data": 2}},
	{"id": "first_scout", "title": "Ojos desde el cielo", "action": "scout", "target": 1, "progress": 0, "claimed": false, "reward": {"credits": 90, "research_data": 3}},
	{"id": "first_trade", "title": "Socio comercial", "action": "trade", "target": 1, "progress": 0, "claimed": false, "reward": {"credits": 60, "research_data": 1}}
]

func register_action(action_id: String) -> void:
	for index in range(contracts.size()):
		var contract: Dictionary = contracts[index]
		if str(contract["action"]) != action_id or bool(contract["claimed"]):
			continue
		contract["progress"] = mini(int(contract["progress"]) + 1, int(contract["target"]))
		if int(contract["progress"]) >= int(contract["target"]):
			contract["claimed"] = true
			contracts[index] = contract
			contract_completed.emit(str(contract["title"]), contract["reward"])
		else:
			contracts[index] = contract
	contracts_changed.emit()

func get_summary_text() -> String:
	var lines := PackedStringArray(["CONTRATOS"])
	for contract in contracts:
		var status := "COMPLETADO" if bool(contract["claimed"]) else "%d/%d" % [int(contract["progress"]), int(contract["target"])]
		lines.append("%s: %s" % [str(contract["title"]), status])
	return "\n".join(lines)

func export_state() -> Dictionary:
	var progress: Array[Dictionary] = []
	for contract in contracts:
		progress.append({
			"id": str(contract.get("id", "")),
			"progress": int(contract.get("progress", 0)),
			"claimed": bool(contract.get("claimed", false))
		})
	return {"version": 1, "contracts": progress}

func import_state(data: Dictionary) -> void:
	var saved_contracts: Variant = data.get("contracts", [])
	if saved_contracts is Array:
		for saved_value in saved_contracts:
			if not saved_value is Dictionary:
				continue
			var saved: Dictionary = saved_value
			var saved_id := str(saved.get("id", ""))
			for index in range(contracts.size()):
				var contract: Dictionary = contracts[index]
				if str(contract.get("id", "")) != saved_id:
					continue
				var target := maxi(1, int(contract.get("target", 1)))
				var progress := clampi(int(saved.get("progress", 0)), 0, target)
				contract["progress"] = progress
				contract["claimed"] = progress >= target and bool(saved.get("claimed", false))
				contracts[index] = contract
				break
	contracts_changed.emit()
