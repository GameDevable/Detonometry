extends Button
@onready var game_button_animator: UiEffectComponent = $GameButtonAnimator
@onready var bounce_animator: UiEffectComponent = $BounceAnimator


func _on_mouse_entered() -> void:
	
	var base_pitch: float = 1.0
	EffectManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)
	var end_scale: Vector2 = Vector2(1.1, 1.1)
	game_button_animator.scale_ui(scale, end_scale, Tween.TRANS_EXPO)


func _on_mouse_exited() -> void:
	var end_scale: Vector2 = Vector2(1.0, 1.0)
	game_button_animator.scale_ui(scale, end_scale, Tween.TRANS_EXPO)


func _on_pressed() -> void:
	bounce_animator.bounce_ui(scale, Constants.MIN_BUTTON_BOUNCE, Constants.MAX_BUTTON_BOUNCE)
	EffectManager.play_sfx(Constants.BUTTON_CLICK_SOUND, 0.0, Constants.BUTTON_CLICK_VOLUME, Constants.BUTTON_CLICK_PITCH)
	UiManager.transition_to("None")
	StatManager.unlocked_upgrades = {}
	get_parent().get_parent().first_loadup = false
	SaveManager.reset_file()
	await get_tree().create_timer(0.5).timeout
	UiManager.show_overlay("Hud")
