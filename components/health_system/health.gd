class_name Health
extends Node
@export var health: int = 10 : set = set_health
@export var max_health: int = 10 : set = set_max_health
var has_depleted: bool = false
func set_health(value: int) -> void:
	health = value

	SignalManager.health_changed.emit(self, abs(health - value))
	if health <= 0 and not has_depleted:
		SignalManager.health_depleted.emit(self)
		has_depleted = true


func set_max_health(value: int) -> void:
	max_health = value
	SignalManager.max_health_changed.emit(abs(max_health - value))
