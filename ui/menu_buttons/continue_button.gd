extends Button
@onready var continue_button_animator: UiEffectComponent = $ContinueButtonAnimator


func _on_mouse_entered() -> void:
	var end_scale: Vector2 = Vector2(1.1, 1.1)
	continue_button_animator.scale_ui(scale, end_scale, Tween.TRANS_EXPO)


func _on_mouse_exited() -> void:
	var end_scale: Vector2 = Vector2(1.0, 1.0)
	continue_button_animator.scale_ui(scale, end_scale, Tween.TRANS_EXPO)


func _on_pressed() -> void:
	UiManager.transition_to("None")
	await get_tree().create_timer(0.5).timeout
	UiManager.show_overlay("Hud")
