extends Panel
@onready var cancel_button: Button = $CancelButton
@onready var cancel_button_animator: UiEffectComponent = $CancelButton/CancelButtonAnimator
@onready var accept_button: Button = $AcceptButton
@onready var accept_button_animator: UiEffectComponent = $AcceptButton/AcceptButtonAnimator


func _on_cancel_button_pressed() -> void:
	EffectManager.play_sfx(Constants.BUTTON_CLICK_SOUND, 0.0, Constants.BUTTON_CLICK_VOLUME, Constants.BUTTON_CLICK_PITCH)
	visible = false


func _on_cancel_button_mouse_entered() -> void:
	var end_scale: Vector2 = Vector2(1.1, 1.1)
	var base_pitch: float = 1.0
	EffectManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)
	cancel_button_animator.scale_ui(cancel_button.scale, end_scale, Tween.TRANS_EXPO)


func _on_cancel_button_mouse_exited() -> void:
	var end_scale: Vector2 = Vector2(1.0, 1.0)
	cancel_button_animator.scale_ui(cancel_button.scale, end_scale, Tween.TRANS_EXPO)


func _on_accept_button_pressed() -> void:
	EffectManager.play_sfx(Constants.BUTTON_CLICK_SOUND, 0.0, Constants.BUTTON_CLICK_VOLUME, Constants.BUTTON_CLICK_PITCH)
	UiManager.transition_to("None")
	StatManager.unlocked_upgrades = {}
	SaveManager.reset_file()
	await get_tree().create_timer(0.5).timeout
	UiManager.show_overlay("Hud")


func _on_accept_button_mouse_entered() -> void:
	var end_scale: Vector2 = Vector2(1.1, 1.1)
	var base_pitch: float = 1.0
	EffectManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)
	accept_button_animator.scale_ui(accept_button.scale, end_scale, Tween.TRANS_EXPO)


func _on_accept_button_mouse_exited() -> void:
	var end_scale: Vector2 = Vector2(1.0, 1.0)
	
	accept_button_animator.scale_ui(accept_button.scale, end_scale, Tween.TRANS_EXPO)
