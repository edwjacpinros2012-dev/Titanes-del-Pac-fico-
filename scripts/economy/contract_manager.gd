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
