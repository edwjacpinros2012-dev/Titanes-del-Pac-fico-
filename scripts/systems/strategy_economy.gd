extends RefCounted
class_name StrategyEconomy

# Pure helper; no scene/UI/network/save side effects. Load balancing from data JSON.
const RESOURCE_KEYS := ["alloy", "energy", "intel", "parts"]
const OFFLINE_CAP_HOURS := 8.0

static func clamp_resources(resources: Dictionary, caps: Dictionary) -> Dictionary:
 var result := resources.duplicate(true)
 for key in RESOURCE_KEYS:
  result[key] = clampi(int(result.get(key, 0)), 0, int(caps.get(key, 0)))
 return result
static func can_afford(resources: Dictionary, cost: Dictionary) -> bool:
 for key in cost.keys():
  if int(resources.get(key, 0)) < int(cost[key]): return false
 return true
static func apply_cost(resources: Dictionary, cost: Dictionary, caps: Dictionary) -> Dictionary:
 if not can_afford(resources, cost): return {"ok": false, "resources": resources.duplicate(true), "reason": "insufficient_resources"}
 var next := resources.duplicate(true)
 for key in cost.keys(): next[key] = int(next.get(key, 0)) - int(cost[key])
 return {"ok": true, "resources": clamp_resources(next, caps), "reason": ""}
static func apply_reward(resources: Dictionary, reward: Dictionary, caps: Dictionary) -> Dictionary:
 var next := resources.duplicate(true)
 for key in reward.keys(): next[key] = int(next.get(key, 0)) + maxi(0, int(reward[key]))
 return clamp_resources(next, caps)
static func calculate_offline_production(rates: Dictionary, elapsed_seconds: float) -> Dictionary:
 var hours := clampf(elapsed_seconds / 3600.0, 0.0, OFFLINE_CAP_HOURS)
 var reward: Dictionary = {}
 for key in rates.keys(): reward[key] = maxi(0, int(floor(float(rates[key]) * hours)))
 return {"elapsed_hours": hours, "reward": reward}
static func storage_caps(base_caps: Dictionary, levels: Dictionary, buildings: Array) -> Dictionary:
 var caps := base_caps.duplicate(true)
 for building in buildings:
  var lvl := maxi(0, int(levels.get(building.get("id", ""), 0)))
  var bonuses: Dictionary = building.get("storage_bonus", {})
  for resource in bonuses.keys(): caps[resource] = int(caps.get(resource, 0)) + int(bonuses[resource]) * lvl
 return caps
