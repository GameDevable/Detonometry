extends Button
@onready var game_button_animator: UiEffectComponent = $GameButtonAnimator


func _on_mouse_entered() -> void:
	var end_scale: Vector2 = Vector2(1.1, 1.1)
	game_button_animator.scale_ui(scale, end_scale, Tween.TRANS_EXPO)


func _on_mouse_exited() -> void:
	var end_scale: Vector2 = Vector2(1.0, 1.0)
	game_button_animator.scale_ui(scale, end_scale, Tween.TRANS_EXPO)


func _on_pressed() -> void:
	UiManager.transition_to("None")
	StatManager.unlocked_upgrades = {}
	get_parent().get_parent().first_loadup = false
	SaveManager.reset_file()
	await get_tree().create_timer(0.5).timeout
	UiManager.show_overlay("Hud")
