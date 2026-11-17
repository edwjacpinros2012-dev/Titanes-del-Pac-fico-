extends RefCounted
class_name ThreatDirector

const PRESSURE_MIN := 0.0
const PRESSURE_MAX := 100.0

func build_threat_brief(context: Dictionary) -> Dictionary:
	var pilot_level := maxi(1, int(context.get("pilot_level", 1)))
	var titan_generation := maxi(1, int(context.get("titan_generation", 1)))
	var titan_condition := clampf(float(context.get("titan_condition", 1.0)), 0.0, 1.0)
	var pilot_sync := clampf(float(context.get("pilot_sync", 0.0)), 0.0, 1.0)
	var base_support := clampf(float(context.get("base_support", 0.0)), 0.0, 1.0)
	var intelligence := clampf(float(context.get("intelligence", 0.0)), 0.0, 1.0)
	var regional_pressure := clampf(float(context.get("regional_pressure", 0.0)), PRESSURE_MIN, PRESSURE_MAX)
	var mission_risk := clampf(float(context.get("mission_risk", 0.0)), 0.0, 1.0)
	var effective_readiness := (
		float(pilot_level) * 0.24 + float(titan_generation) * 0.34
		+ titan_condition * 2.0 + pilot_sync * 1.2
		+ base_support * 1.1 + intelligence * 0.8
	)
	var threat_score := effective_readiness * 0.48 + regional_pressure / 100.0 * 2.2 + mission_risk * 1.4
	var tier := clampi(1 + int(floor(threat_score / 2.2)), 1, 10)
	var warning := "Baja"
	if tier >= 8:
		warning = "Crítica"
	elif tier >= 5:
		warning = "Elevada"
	elif tier >= 3:
		warning = "Moderada"
	var notes: Array[String] = []
	if titan_condition < 0.55:
		notes.append("Reparar el Centinela antes de desplegar.")
	if pilot_sync < 0.35:
		notes.append("Mejorar la sincronización de pilotos.")
	if intelligence < 0.3:
		notes.append("Enviar reconocimiento para reducir incertidumbre.")
	if base_support < 0.3:
		notes.append("Revisar suministros y apoyo del hangar.")
	if regional_pressure >= 70.0:
		notes.append("La presión regional es alta: considerar una operación de contención.")
	return {
		"tier": tier, "warning": warning, "score": snappedf(threat_score, 0.1),
		"regional_pressure": regional_pressure, "readiness": snappedf(effective_readiness, 0.1),
		"preparation_notes": notes, "fair_warning": true
	}

func apply_outcome(current_pressure: float, outcome: String) -> float:
	var delta := 0.0
	match outcome:
		"victory": delta = -14.0
		"partial": delta = -5.0
		"retreat": delta = 3.0
		"defeat": delta = 9.0
		_: return clampf(current_pressure, PRESSURE_MIN, PRESSURE_MAX)
	return clampf(current_pressure + delta, PRESSURE_MIN, PRESSURE_MAX)
