extends "res://components/shape/shape_modifier_component.gd"
const BOUNCY_BALL = preload("uid://cegm36xr2lexh")

func activate_ability() -> void:
	var b_ball = BOUNCY_BALL.instantiate()
	b_ball.global_position = shape.global_position
	shape.get_parent().call_deferred("add_child", b_ball)
