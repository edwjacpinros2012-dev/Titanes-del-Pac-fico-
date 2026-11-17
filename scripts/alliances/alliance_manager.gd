extends Node
class_name AllianceManager
signal alliance_changed(summary: String)
signal message_added(message: String)
var alliance_name := ""
var alliance_tag := ""
var rank := "Sin alianza"
var members: Array[Dictionary] = []
var objectives: Array[Dictionary] = [
 {"id":"scout_sector","title":"Explorar un sector","target":3,"progress":0,"reward":120},
 {"id":"research_kaiju","title":"Investigar Kaijus","target":5,"progress":0,"reward":180},
 {"id":"support_defense","title":"Apoyar la defensa","target":2,"progress":0,"reward":150}
]
var local_chat: Array[String] = []
var blocked_terms := ["dato privado","contraseña","amenaza personal"]
func create_alliance(display_name: String, tag: String) -> bool:
 var clean_name := display_name.strip_edges()
 var clean_tag := tag.strip_edges().to_upper()
 if clean_name.length() < 3 or clean_name.length() > 24 or clean_tag.length() < 2 or clean_tag.length() > 5: return false
 alliance_name = clean_name
 alliance_tag = clean_tag
 rank = "Comandante"
 members = [{"name":"Comandante","rank":"Comandante","contribution":0}]
 alliance_changed.emit(get_summary())
 return true
func join_demo_alliance() -> bool:
 if not alliance_name.is_empty(): return false
 alliance_name = "Guardianes del Abismo"
 alliance_tag = "GDA"
 rank = "Recluta"
 members = [{"name":"Comandante","rank":"Comandante","contribution":120},{"name":"Oficial Mareas","rank":"Oficial","contribution":85},{"name":"Piloto Norte","rank":"Piloto","contribution":40},{"name":"Tú","rank":"Recluta","contribution":0}]
 alliance_changed.emit(get_summary())
 return true
func add_contribution(amount: int) -> void:
 if alliance_name.is_empty() or members.is_empty(): return
 var last_member: Dictionary = members[members.size() - 1]
 last_member["contribution"] = int(last_member.get("contribution",0)) + maxi(0,amount)
 members[members.size() - 1] = last_member
 alliance_changed.emit(get_summary())
func register_objective(action: String) -> void:
 var map := {"scout":"scout_sector","research":"research_kaiju","defense":"support_defense"}
 if not map.has(action): return
 for objective in objectives:
  if objective["id"] == map[action] and int(objective["progress"]) < int(objective["target"]):
   objective["progress"] = int(objective["progress"]) + 1
   if int(objective["progress"]) >= int(objective["target"]): message_added.emit("Objetivo de alianza completado: " + str(objective["title"]))
   alliance_changed.emit(get_summary())
   return
func post_local_message(sender: String, body: String) -> bool:
 var clean := body.strip_edges()
 if clean.is_empty() or clean.length() > 240 or sender.length() > 20: return false
 var lower := clean.to_lower()
 for term in blocked_terms:
  if lower.contains(term):
   message_added.emit("Mensaje retenido por el filtro de seguridad.")
   return false
 var line := "[%s] %s: %s" % [Time.get_time_string_from_system(),sender,clean]
 local_chat.append(line)
 if local_chat.size() > 30: local_chat.pop_front()
 message_added.emit(line)
 return true
func get_summary() -> String:
 if alliance_name.is_empty(): return "ALIANZA: No perteneces a ninguna. Crea una o prueba la alianza de demostración."
 var completed := 0
 for objective in objectives:
  if int(objective["progress"]) >= int(objective["target"]): completed += 1
 return "ALIANZA [%s] %s | Rango: %s | Miembros: %d | Objetivos: %d/%d" % [alliance_tag,alliance_name,rank,members.size(),completed,objectives.size()]
