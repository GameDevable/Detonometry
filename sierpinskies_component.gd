extends "res://components/shape/shape_modifier_component.gd"
const SIERPINSKIES_COMPONENT = preload("uid://bdacywg0y6sha")

func apply_modifier() -> void:
	pass


func activate_ability() -> void:
	var modifier_arrays_array: Array[Array] = [[], [], []]
	for i in range(3):
		var chance_roll: int = randi_range(0, 100)
		var frac_chance: float = StatManager.get_special_modifier_stat("fractalization_chance") 
		if chance_roll <= frac_chance and frac_chance != 0:
			modifier_arrays_array[i] = [SIERPINSKIES_COMPONENT]
	SignalManager.spawn_sierpinski_triangles.emit(shape.position, modifier_arrays_array)
