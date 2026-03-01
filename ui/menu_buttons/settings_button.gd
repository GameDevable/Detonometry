extends Button
@onready var settings_button_animator: UiEffectComponent = $SettingsButtonAnimator


func _on_mouse_entered() -> void:
	var end_scale: Vector2 = Vector2(1.1, 1.1)
	settings_button_animator.scale_ui(scale, end_scale, Tween.TRANS_EXPO)


func _on_mouse_exited() -> void:
	var end_scale: Vector2 = Vector2(1.0, 1.0)
	settings_button_animator.scale_ui(scale, end_scale, Tween.TRANS_EXPO)


func _on_pressed() -> void:
	UiManager.transition_to("SettingsMenu")
