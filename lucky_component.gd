extends "res://components/shape/shape_modifier_component.gd"

func apply_modifier() -> void:
	shape.modifier_multipliers_total *= StatManager.get_special_modifier_stat("lucky_triangle_multiplier")
