extends Node
# bombs
var bomb_stats: Dictionary[String, float] = {
	"damage" : 1.0,
	"explosion_radius": 77.0,
	"explosion_radius_size_percent": 100.0,
	"explosion_time": 1.5,
	"place_delay": 3.5,
}

# Shape Spawning
var shape_spawn_stats: Dictionary[String, float] = {
	"spawn_limit": 5,
	"bunch_spawn_chance": 2,
	"bunch_spawn_number": 2,
	"spawn_time": 2.5,
}
var despawn_time_multiplier: float = 2.1
var despawn_threshold_ratio: float = 0.75


var shape_type_weights: Dictionary[Enums.ShapeType, float] = {
	Enums.ShapeType.TRIANGLE : 1.0,
	Enums.ShapeType.SQUARE : 0.0,
	Enums.ShapeType.PENTAGON : 0.0,
	Enums.ShapeType.HEXAGON : 0.0,
	Enums.ShapeType.CIRCLE : 0.0
}


var shape_stats: Dictionary[Enums.ShapeType, Dictionary] = {
	Enums.ShapeType.TRIANGLE : {"points" : 1, "health" : 1},
	Enums.ShapeType.SQUARE : {"points" : 1, "health" : 1},
	Enums.ShapeType.PENTAGON : {"points" : 1, "health" : 1},
	Enums.ShapeType.HEXAGON : {"points" : 1, "health" : 1},
	Enums.ShapeType.CIRCLE : {"points" : 1, "health" : 1},
}

var special_modifier_stats: Dictionary[String, float] = {
	"sierpinskies_triangle_chance": 0.0,
	"fractalization_chance": 0.0,
	"subtriangle_value" : 1.0,
	"lucky_triangle_chance": 0.0,
	"lucky_triangle_multiplier": 5.0,
	"reinforced_triangle_chance": 0.0,
}

var bonus_stats: Dictionary[String, float] = {
	
}

var multiplier_stats: Dictionary[String, float] = {
	"cluster_multiplier" : 1.0,
	"cluster_threshold" : 3.0,
	"cluster_exceed_bonus" : 0.0,
}
var unlocked_upgrades: Dictionary[String, Upgrade] = {}

func get_bomb_stats() -> Dictionary[String, float]:
	return bomb_stats


func get_bomb_stat(key: String) -> float:
	if unlocked_upgrades.has(key):
		var upgrade: Upgrade = unlocked_upgrades[key]
		var upgraded_stat: float = upgrade.get_upgraded_stat()
		return upgraded_stat
	if key == "explosion_radius":
		return Constants.BASE_BOMB_RADIUS * (get_bomb_stat("explosion_radius_size_percent") / 100.0)
	return bomb_stats[key]


func get_bonus_stat(key: String) -> float:
	if unlocked_upgrades.has(key):
		var upgrade: Upgrade = unlocked_upgrades[key]
		var upgraded_stat: float = upgrade.get_upgraded_stat()
		return upgraded_stat
	return bonus_stats[key]


func get_multiplier_stat(key: String) -> float:
	if unlocked_upgrades.has(key):
		var upgrade: Upgrade = unlocked_upgrades[key]
		var upgraded_stat: float = upgrade.get_upgraded_stat()
		return upgraded_stat
	return multiplier_stats[key]


func get_shape_spawn_stats() -> Dictionary[String, float]:
	return shape_spawn_stats


func get_shape_spawn_stat(key: String) -> float:
	if unlocked_upgrades.has(key):
		var upgrade: Upgrade = unlocked_upgrades[key]
		var upgraded_stat: float = upgrade.get_upgraded_stat()
		return upgraded_stat
	return shape_spawn_stats[key]


func get_shape_type_weights() -> Dictionary[Enums.ShapeType, float]:
	return shape_type_weights


func get_despawn_threshold() -> float:
	return shape_spawn_stats["spawn_limit"] * despawn_threshold_ratio




func get_despawn_time() -> float:
	return shape_spawn_stats["spawn_time"] * despawn_time_multiplier


func get_shape_value(shape_type: Enums.ShapeType) -> int:
	var shape_name: String = Enums.ShapeType.keys()[shape_type].to_lower()
	var upgrade_key: String = shape_name + "_value"
	if unlocked_upgrades.has(upgrade_key):
		var upgrade: Upgrade = unlocked_upgrades[upgrade_key]
		var upgraded_shape_value: float = upgrade.get_upgraded_stat()
		return int(upgraded_shape_value) 
	return shape_stats[shape_type]["points"] 


func get_shape_health(shape_type: Enums.ShapeType) -> int:
	return shape_stats[shape_type]["health"]


func get_special_modifier_stat(key: String) -> float:
	return special_modifier_stats[key]
