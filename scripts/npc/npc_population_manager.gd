extends Node3D
class_name NpcPopulationManager

signal npc_interacted(message: String)
signal community_changed(summary: String)

const INTERACTION_DISTANCE := 8.0
const SHIFT_DURATION := 45.0
const NPC_DEFINITIONS := [
	{"id":"mara","name":"Mara Velez","role":"Ingeniera jefe","color":Color(0.95,0.55,0.22),"home":Vector3(-3,0,-1),"route":[Vector3(-3,0,-1),Vector3(-5,0,-4),Vector3(-2,0,-7)],"dialogue":"El hangar necesita mantenimiento. Un Centinela bien cuidado protege a todos."},
	{"id":"ivo","name":"Ivo Soria","role":"Jefe de reconocimiento","color":Color(0.25,0.72,0.88),"home":Vector3(3,0,-1),"route":[Vector3(3,0,-1),Vector3(5,0,-4),Vector3(3,0,-8)],"dialogue":"Los sensores detectan movimientos en la costa. Nunca salgas sin información."},
	{"id":"lina","name":"Lina Arce","role":"Científica","color":Color(0.65,0.48,0.9),"home":Vector3(-5,0,-5),"route":[Vector3(-5,0,-5),Vector3(-2,0,-8),Vector3(-4,0,-11)],"dialogue":"Cada brecha deja datos. Podemos convertir esos descubrimientos en tecnología."},
	{"id":"tarek","name":"Tarek Mena","role":"Intendente","color":Color(0.75,0.72,0.35),"home":Vector3(0,0,-5),"route":[Vector3(0,0,-5),Vector3(2,0,-7),Vector3(0,0,-10)],"dialogue":"El almacén no se llena solo. Mantén el comercio y los suministros en movimiento."},
	{"id":"sena","name":"Sena Cruz","role":"Comandante de defensa","color":Color(0.8,0.28,0.28),"home":Vector3(5,0,-5),"route":[Vector3(5,0,-5),Vector3(4,0,-8),Vector3(6,0,-11)],"dialogue":"La costa depende de nuestras decisiones. Una retirada inteligente también puede salvar el frente."},
	{"id":"yara","name":"Yara Solis","role":"Médica de campaña","color":Color(0.35,0.8,0.55),"home":Vector3(-3,0,-9),"route":[Vector3(-3,0,-9),Vector3(-1,0,-11),Vector3(-4,0,-13)],"dialogue":"Después de cada operación revisa el estado del mecha. No ignores las averías."},
	{"id":"ken","name":"Ken Vidal","role":"Piloto de apoyo","color":Color(0.3,0.62,0.92),"home":Vector3(3,0,-9),"route":[Vector3(3,0,-9),Vector3(5,0,-12),Vector3(2,0,-13)],"dialogue":"Los registros de criaturas nos ayudan a anticipar el comportamiento de los Abisales."},
	{"id":"eva","name":"Eva Paredes","role":"Representante civil","color":Color(0.9,0.58,0.68),"home":Vector3(0,0,-13),"route":[Vector3(0,0,-13),Vector3(-2,0,-15),Vector3(2,0,-15)],"dialogue":"La población necesita seguridad, energía y noticias claras sobre la guerra."}
]

const REQUESTS := [
	{"title":"Suministros para el hangar","action":"collect","target":3,"reward":{"metal":8,"credits":35}},
	{"title":"Informe de reconocimiento","action":"scout","target":1,"reward":{"research_data":4,"credits":45}},
	{"title":"Muestras de una brecha","action":"rift","target":1,"reward":{"cristal":3,"research_data":3}},
	{"title":"Reactivar el intercambio","action":"trade","target":1,"reward":{"metal":5,"energia":5,"credits":40}},
	{"title":"Defender la costa","action":"victory","target":1,"reward":{"metal":7,"research_data":5,"credits":60}},
	{"title":"Revisión de mantenimiento","action":"repair","target":1,"reward":{"energia":8,"credits":30}},
	{"title":"Catálogo de fauna hostil","action":"observe","target":1,"reward":{"research_data":5,"cristal":1}},
	{"title":"Apoyo a la comunidad","action":"collect","target":2,"reward":{"energia":6,"credits":25}}
]

var npc_records: Array[Dictionary] = []
var active_request: Dictionary = {}
var request_cursor := 0
var community_morale := 65
var public_trust := 10
var security_alert := 0
var shift_clock := 0.0
var current_shift := 0
var last_message := "Habla con el personal de la base para conocer sus solicitudes."

func _ready() -> void:
	_spawn_population()

func _process(delta: float) -> void:
	shift_clock += delta
	if shift_clock >= SHIFT_DURATION:
		shift_clock = 0.0
		current_shift = (current_shift + 1) % 4
		_update_routines()
	for record in npc_records:
		var actor: Node3D = record.get("actor")
		if not is_instance_valid(actor):
			continue
		var target: Vector3 = record.get("target", actor.position)
		var direction := target - actor.position
		if direction.length() > 0.12:
			actor.position += direction.normalized() * minf(0.85 * delta, direction.length())
			actor.look_at(Vector3(target.x, actor.position.y, target.z), Vector3.UP)

func _spawn_population() -> void:
	for definition in NPC_DEFINITIONS:
		var actor := Node3D.new()
		actor.name = "NPC_" + str(definition["id"])
		actor.position = definition["home"]
		var body := MeshInstance3D.new()
		var capsule := CapsuleMesh.new()
		capsule.radius = 0.38
		capsule.height = 1.35
		body.mesh = capsule
		body.position.y = 0.78
		body.material_override = _make_material(definition["color"])
		actor.add_child(body)
		var head := MeshInstance3D.new()
		var head_mesh := SphereMesh.new()
		head_mesh.radius = 0.27
		head_mesh.height = 0.54
		head.mesh = head_mesh
		head.position.y = 1.62
		head.material_override = _make_material(Color(0.72,0.62,0.52))
		actor.add_child(head)
		var label := Label3D.new()
		label.text = str(definition["name"]) + "\n" + str(definition["role"])
		label.position.y = 2.15
		label.font_size = 32
		label.pixel_size = 0.004
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		actor.add_child(label)
		add_child(actor)
		var route: Array = definition["route"]
		npc_records.append({
			"id":definition["id"], "name":definition["name"], "role":definition["role"],
			"dialogue":definition["dialogue"], "actor":actor, "route":route,
			"route_index":0, "target":route[0], "trust":10, "mood":"En servicio"
		})

func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	return material

func _update_routines() -> void:
	for record in npc_records:
		var route: Array = record["route"]
		var offset := current_shift % route.size()
		record["route_index"] = offset
		record["target"] = route[offset]
		record["mood"] = "En turno" if community_morale >= 40 else "Preocupado"

func interact_nearest(player: Node3D) -> Dictionary:
	if not is_instance_valid(player):
		return {"message":"No se detecta al piloto."}
	var nearest: Dictionary = {}
	var nearest_distance := INTERACTION_DISTANCE
	for record in npc_records:
		var actor: Node3D = record["actor"]
		var distance := player.global_position.distance_to(actor.global_position)
		if distance <= nearest_distance:
			nearest_distance = distance
			nearest = record
	if nearest.is_empty():
		return {"message":"Acércate a una persona de la base para conversar."}
	var npc_id := str(nearest["id"])
	var message := str(nearest["name"]) + " — " + str(nearest["role"]) + ": " + str(nearest["dialogue"])
	var reward: Dictionary = {}
	if not active_request.is_empty():
		if str(active_request.get("npc_id","")) != npc_id:
			message += "\nSolicitud activa: " + str(active_request.get("title","")) + " (%d/%d). Vuelve con " % [int(active_request.get("progress",0)),int(active_request.get("target",1))] + str(_get_npc_name(str(active_request.get("npc_id","")))) + "."
		elif int(active_request.get("progress",0)) >= int(active_request.get("target",1)):
			reward = active_request.get("reward",{}).duplicate(true)
			message += "\n¡Solicitud completada! Recompensa entregada: " + str(reward)
			active_request = {}
			request_cursor = (request_cursor + 1) % REQUESTS.size()
			public_trust = mini(100, public_trust + 3)
			community_morale = mini(100, community_morale + 2)
		else:
			message += "\nSolicitud: " + str(active_request.get("title","")) + " — %d/%d" % [int(active_request.get("progress",0)),int(active_request.get("target",1))]
	else:
		var request: Dictionary = REQUESTS[request_cursor].duplicate(true)
		request["npc_id"] = npc_id
		request["progress"] = 0
		active_request = request
		message += "\nNueva solicitud: " + str(request["title"]) + ". Objetivo: %d %s. La tarea queda activa." % [int(request["target"]),str(request["action"])]
	last_message = message
	npc_interacted.emit(message)
	community_changed.emit(get_status_text())
	return {"message":message,"reward":reward}

func register_action(action_id: String) -> void:
	if active_request.is_empty() or str(active_request.get("action","")) != action_id:
		return
	active_request["progress"] = mini(int(active_request.get("progress",0)) + 1, int(active_request.get("target",1)))
	community_changed.emit(get_status_text())

func register_battle_result(outcome: String) -> void:
	match outcome:
		"victory":
			community_morale = mini(100, community_morale + 6)
			security_alert = maxi(0, security_alert - 2)
		"partial_success":
			community_morale = mini(100, community_morale + 2)
			security_alert = maxi(0, security_alert - 1)
		"retreat":
			community_morale = maxi(0, community_morale - 2)
			security_alert = mini(100, security_alert + 1)
		"defeat":
			community_morale = maxi(0, community_morale - 8)
			security_alert = mini(100, security_alert + 3)
	community_changed.emit(get_status_text())

func register_base_upgrade() -> void:
	community_morale = mini(100, community_morale + 1)
	community_changed.emit(get_status_text())

func get_status_text() -> String:
	var request_text := "Sin solicitudes activas"
	if not active_request.is_empty():
		request_text = "%s: %d/%d" % [str(active_request.get("title","")),int(active_request.get("progress",0)),int(active_request.get("target",1))]
	return "PERSONAL DE BASE: %d | ÁNIMO %d/100 | CONFIANZA %d/100 | ALERTA %d/100\n%s" % [
		npc_records.size(), community_morale, public_trust, security_alert, request_text
	]

func export_state() -> Dictionary:
	return {
		"version":1, "community_morale":community_morale, "public_trust":public_trust,
		"security_alert":security_alert, "request_cursor":request_cursor,
		"active_request":active_request.duplicate(true)
	}

func import_state(data: Dictionary) -> void:
	community_morale = clampi(int(data.get("community_morale",65)),0,100)
	public_trust = clampi(int(data.get("public_trust",10)),0,100)
	security_alert = clampi(int(data.get("security_alert",0)),0,100)
	request_cursor = posmod(int(data.get("request_cursor",0)),REQUESTS.size())
	var saved_request: Variant = data.get("active_request",{})
	active_request = saved_request.duplicate(true) if saved_request is Dictionary else {}
	community_changed.emit(get_status_text())

func _get_npc_name(npc_id: String) -> String:
	for record in npc_records:
		if str(record["id"]) == npc_id:
			return str(record["name"])
	return "el personal"
