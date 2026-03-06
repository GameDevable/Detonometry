extends Button
@onready var quit_button_animator: UiEffectComponent = $QuitButtonAnimator


func _on_mouse_entered() -> void:
	var base_pitch: float = 1.0
	EffectManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)
	var end_scale: Vector2 = Vector2(1.1, 1.1)
	quit_button_animator.scale_ui(scale, end_scale, Tween.TRANS_EXPO)


func _on_mouse_exited() -> void:
	var end_scale: Vector2 = Vector2(1.0, 1.0)
	quit_button_animator.scale_ui(scale, end_scale, Tween.TRANS_EXPO)


func _on_pressed() -> void:
	EffectManager.play_sfx(Constants.BUTTON_CLICK_SOUND, 0.0, Constants.BUTTON_CLICK_VOLUME, Constants.BUTTON_CLICK_PITCH)
	get_tree().quit()
