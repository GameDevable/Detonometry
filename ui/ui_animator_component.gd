extends Node

func scale_parent(final_scale: Vector2, minimum_size: Vector2, time: float, easing: Tween.EaseType, transition: Tween.TransitionType) -> void:
	var scale_tween: Tween = get_tree().create_tween().set_ease(easing).set_trans(transition)
	var parent: Control = get_parent()
	scale_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	scale_tween.tween_property(parent, "custom_minimum_size", minimum_size * final_scale, time)


func scale_custom_scale_parent(final_scale: Vector2, time: float, easing: Tween.EaseType, transition: Tween.TransitionType) -> void:
	var scale_tween: Tween = get_tree().create_tween().set_ease(easing).set_trans(transition)
	var parent: Control = get_parent()
	# Makes sure it runs since the tree is currently paused
	scale_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	scale_tween.tween_property(parent, "size", parent.custom_minimum_size * final_scale, time)


func bounce() -> void:
	var base_scale = get_parent().scale
	pass


func pulse() -> void:
	pass
