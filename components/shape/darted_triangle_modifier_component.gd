extends "res://components/shape/shape_modifier_component.gd"
const TRIANGLE_DART = preload("uid://b5w7t2o7lckpe")

func apply_modifier() -> void:
	pass


func activate_ability() -> void:
	var dart1: CharacterBody2D = TRIANGLE_DART.instantiate()
	var dart2: CharacterBody2D = TRIANGLE_DART.instantiate()
	var dart3: CharacterBody2D = TRIANGLE_DART.instantiate()
	
	
	var move_direction1: Vector2 = Vector2.UP
	var move_direction2: Vector2 = Vector2(1.2, 1)
	var move_direction3: Vector2 = Vector2(-1.2, 1)
	
	dart1.global_position = shape.global_position
	dart2.global_position = shape.global_position
	dart3.global_position = shape.global_position
	
	dart1.movement_direction = move_direction1.rotated(shape.rotation).normalized()
	dart2.movement_direction = move_direction2.rotated(shape.rotation).normalized()
	dart3.movement_direction = move_direction3.rotated(shape.rotation).normalized()
	
	dart1.rotation = dart1.movement_direction.angle() + PI / 2
	dart2.rotation = dart2.movement_direction.angle() + PI / 2
	dart3.rotation = dart3.movement_direction.angle() + PI / 2
	
	shape.get_parent().get_parent().get_parent().call_deferred("add_child", dart1)
	shape.get_parent().get_parent().get_parent().call_deferred("add_child", dart2)
	shape.get_parent().get_parent().get_parent().call_deferred("add_child", dart3)
