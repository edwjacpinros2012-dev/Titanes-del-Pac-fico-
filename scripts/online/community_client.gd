extends Node
class_name CommunityClient

signal auth_changed(is_authenticated: bool, message: String)
signal chat_received(messages: Array)
signal request_failed(message: String)

var supabase_url := ""
var anon_key := ""
var access_token := ""
var user_id := ""
var user_email := ""

func configure(project_url: String, public_anon_key: String) -> bool:
	supabase_url = project_url.strip_edges().trim_suffix("/")
	anon_key = public_anon_key.strip_edges()
	return supabase_url.begins_with("https://") and not anon_key.is_empty()

func sign_up(email: String, password: String) -> Dictionary:
	if not _configured(): return _fail("Configura la URL y la clave pública de Supabase.")
	if password.length() < 10: return _fail("La contraseña debe tener al menos 10 caracteres.")
	var result := await _request(HTTPClient.METHOD_POST, "/auth/v1/signup", {"email":email.strip_edges(),"password":password})
	if int(result.get("status",0)) in [200,201]:
		_store_auth(result.get("data",{}))
		auth_changed.emit(not access_token.is_empty(), "Cuenta creada. Si se solicita, confirma tu correo.")
	return result

func register_profile(handle: String, display_name: String) -> bool:
	if access_token.is_empty() or handle.length() < 3 or handle.length() > 20:
		return false
	var handle_regex := RegEx.new()
	handle_regex.compile("^[A-Za-z0-9_]{3,20}$")
	if handle_regex.search(handle) == null:
		return false
	var payload := {"user_id":user_id,"handle":handle,"display_name":display_name.substr(0,24),"global_chat_enabled":false}
	var result := await _request(HTTPClient.METHOD_POST, "/rest/v1/player_profiles", payload, true)
	return int(result.get("status",0)) in [200,201,204]

func sign_in(email: String, password: String) -> Dictionary:
	if not _configured(): return _fail("Configura la URL y la clave pública de Supabase.")
	var result := await _request(HTTPClient.METHOD_POST, "/auth/v1/token?grant_type=password", {"email":email.strip_edges(),"password":password})
	if int(result.get("status",0)) == 200:
		_store_auth(result.get("data",{}))
		auth_changed.emit(true, "Sesión iniciada.")
	else:
		request_failed.emit("No se pudo iniciar sesión. Revisa los datos y la configuración.")
	return result

func sign_out() -> void:
	if not access_token.is_empty():
		await _request(HTTPClient.METHOD_POST, "/auth/v1/logout", {})
	access_token = ""
	user_id = ""
	user_email = ""
	auth_changed.emit(false, "Sesión cerrada.")

func fetch_global_chat() -> Array:
	if access_token.is_empty(): return []
	var result := await _request(HTTPClient.METHOD_GET, "/rest/v1/chat_messages?select=id,sender_id,body,created_at&channel=eq.global&moderation_state=eq.visible&order=created_at.desc&limit=40", {})
	if int(result.get("status",0)) == 200 and typeof(result.get("data")) == TYPE_ARRAY:
		chat_received.emit(result["data"])
		return result["data"]
	return []

func send_chat_message(body: String, channel: String = "global", alliance_id: String = "") -> bool:
	var clean := body.strip_edges()
	if access_token.is_empty() or clean.is_empty() or clean.length() > 240:
		request_failed.emit("Inicia sesión y escribe un mensaje de 1 a 240 caracteres.")
		return false
	if channel not in ["global","alliance"]:
		return false
	var payload := {"channel":channel,"sender_id":user_id,"body":clean,"moderation_state":"pending"}
	if channel == "alliance":
		if alliance_id.is_empty(): return false
		payload["alliance_id"] = alliance_id
	var result := await _request(HTTPClient.METHOD_POST, "/rest/v1/chat_messages", payload, true)
	return int(result.get("status",0)) in [200,201,204]

func report_player(reported_user_id: String, category: String, details: String = "") -> bool:
	if access_token.is_empty() or category not in ["harassment","spam","inappropriate_content","personal_information","cheating","other"]:
		return false
	var payload := {"reporter_id":user_id,"reported_user_id":reported_user_id,"category":category,"details":details.substr(0,500)}
	var result := await _request(HTTPClient.METHOD_POST, "/rest/v1/player_reports", payload, true)
	return int(result.get("status",0)) in [200,201,204]

func block_player(blocked_user_id: String) -> bool:
	if access_token.is_empty() or blocked_user_id == user_id or blocked_user_id.is_empty(): return false
	var result := await _request(HTTPClient.METHOD_POST, "/rest/v1/player_blocks", {"blocker_id":user_id,"blocked_id":blocked_user_id}, true)
	return int(result.get("status",0)) in [200,201,204]

func _request(method: int, path: String, payload: Dictionary, prefer_return: bool = false) -> Dictionary:
	var http := HTTPRequest.new()
	add_child(http)
	var headers := PackedStringArray(["apikey: " + anon_key, "Content-Type: application/json"])
	if not access_token.is_empty():
		headers.append("Authorization: Bearer " + access_token)
	else:
		headers.append("Authorization: Bearer " + anon_key)
	if prefer_return:
		headers.append("Prefer: return=minimal")
	var body := "" if method == HTTPClient.METHOD_GET else JSON.stringify(payload)
	var request_error := http.request(supabase_url + path, headers, method, body)
	if request_error != OK:
		http.queue_free()
		return {"status":0,"data":{},"error":"No se pudo iniciar la solicitud HTTP."}
	var response: Array = await http.request_completed
	http.queue_free()
	var status := int(response[1])
	var raw: PackedByteArray = response[3]
	var parsed: Variant = JSON.parse_string(raw.get_string_from_utf8()) if raw.size() > 0 else {}
	return {"status":status,"data":parsed if parsed != null else {},"error":"" if status in range(200,300) else "La solicitud fue rechazada por el servicio."}

func _store_auth(data: Variant) -> void:
	if typeof(data) != TYPE_DICTIONARY: return
	access_token = str(data.get("access_token",""))
	var user: Dictionary = data.get("user",{})
	user_id = str(user.get("id",""))
	user_email = str(user.get("email",""))

func _configured() -> bool:
	return supabase_url.begins_with("https://") and not anon_key.is_empty()

func _fail(message: String) -> Dictionary:
	request_failed.emit(message)
	return {"status":0,"data":{},"error":message}
