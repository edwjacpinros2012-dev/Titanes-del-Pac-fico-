extends Node
class_name CampaignManager
signal chapter_changed(chapter_name: String, player_level: int)
var player_level := 1
var jaeger_generation := 1
var current_chapter := "Primer contacto"
var chapters: Array[Dictionary] = [
 {"level":1,"name":"Primer contacto","threat":1},
 {"level":5,"name":"Frente costero","threat":2},
 {"level":12,"name":"Frontera abisal","threat":3},
 {"level":22,"name":"Crisis mundial","threat":4},
 {"level":35,"name":"Origen de la brecha","threat":5}
]
func add_experience(amount: int) -> bool:
 if amount <= 0: return false
 player_level += amount
 if player_level >= 35: jaeger_generation = 5
 elif player_level >= 20: jaeger_generation = 4
 elif player_level >= 10: jaeger_generation = 3
 elif player_level >= 5: jaeger_generation = 2
 var selected: Dictionary = chapters[0]
 for chapter in chapters:
  if player_level >= int(chapter["level"]): selected = chapter
 var changed := current_chapter != str(selected["name"])
 current_chapter = str(selected["name"])
 if changed: chapter_changed.emit(current_chapter,player_level)
 return changed
func get_summary() -> String:
 return "CAMPAÑA: %s | Nivel %d | Jaeger Mark %d" % [current_chapter,player_level,jaeger_generation]
