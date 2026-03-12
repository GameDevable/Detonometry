extends "res://components/shape/shape_modifier_component.gd"

func apply_modifier() -> void:
	shape.health.health *= 2
	shape.health.max_health *= 2
	shape.modifier_multipliers_total *= StatManager.get_special_modifier_stat("reinforced_triangle_multiplier")
