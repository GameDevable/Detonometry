extends "res://components/shape/shape_modifier_component.gd"

func activate_ability() -> void:
	SignalManager.spawn_bomb.emit(shape.global_position)
