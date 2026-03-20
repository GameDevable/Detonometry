extends Control
@onready var upgrade_hub_button: Button = $UpgradeHubButton
@onready var continue_button: Button = $ContinueButton
@onready var upgrade_hub_button_animator: UiEffectComponent = $UpgradeHubButton/UpgradeHubButtonAnimator
@onready var continue_button_animator: UiEffectComponent = $ContinueButton/ContinueButtonAnimator

@onready var ui_effect_component: UiEffectComponent = $UiEffectComponent

var current_session_data: Array[int] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.session_ended.connect(_on_session_ended)


func handle_shown() -> void:
	UiManager.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON)
	scale = Vector2(0.01, 0.01)
	ui_effect_component.scale_ui(Vector2(0.01, 0.01), Vector2(1.0, 1.0), Tween.TRANS_EXPO)



func _on_session_ended(data: Array[int]) -> void:
	current_session_data = data
	SignalManager.points_changed.emit(data[1])


func _tween_label_int(label: Label, starting_value: int, ending_value: int, is_money: bool, time: float) -> void:
	var tween := create_tween()
	tween.tween_method(
		func(value):
			var display_value: int = int(value)
			if is_money:
				label.text = "$" + str(display_value)
			else:
				label.text = " " + str(display_value),
		starting_value,
		ending_value,
		time
	)


func _tween_label_float(label: Label, starting_value: float, ending_value: float, is_money: bool, time: float) -> void:
	var tween := create_tween()
	tween.tween_method(
		func(value):
			var display_value: float = snapped(value, 0.01) # keep 2 decimals
			if is_money:
				label.text = "$" + str(display_value)
			else:
				label.text = "x" + str(display_value),
		starting_value,
		ending_value,
		time
	)


func _play_click():
	EffectManager.play_sfx(
		Constants.BUTTON_CLICK_SOUND,
		0.0,
		Constants.BUTTON_CLICK_VOLUME,
		Constants.BUTTON_CLICK_PITCH
	)

func _play_hover():
	EffectManager.play_sfx(
		Constants.BUTTON_HOVER_SOUND,
		0.0,
		Constants.ENTER_BUTTON_VOLUME,
		1.0,
		true,
		Constants.ENTER_PITCH_RANGE
	)


func _scale_label_font(label: Label, font_scale: float, duration: float) -> void:
	var tween := create_tween()
	
	var base_size: float = label.get_theme_font_size("font_size")
	var target_size: float = base_size * font_scale
	
	tween.tween_method(
		func(size):
			label.add_theme_font_size_override("font_size", size),
		base_size,
		target_size,
		duration
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


func _scale_button(animator: UiEffectComponent, button: Button, button_scale: Vector2) -> void:
	animator.scale_ui(button.scale, button_scale, Tween.TRANS_EXPO)


# --- Upgrade Hub Button ---

func _on_upgrade_hub_button_pressed() -> void:
	_play_click()
	UiManager.transition_to("UpgradeHub")
	await get_tree().create_timer(0.01).timeout
	UiManager.hide_overlay("SessionSummary")

func _on_upgrade_hub_button_mouse_entered() -> void:
	_play_hover()
	_scale_button(upgrade_hub_button_animator, upgrade_hub_button, Vector2(1.05, 1.05))

func _on_upgrade_hub_button_mouse_exited() -> void:
	_scale_button(upgrade_hub_button_animator, upgrade_hub_button, Vector2(1.0, 1.0))


# --- Continue Button ---

func _on_continue_button_pressed() -> void:
	_play_click()
	UiManager.transition_to("None")
	await get_tree().create_timer(0.35).timeout
	UiManager.show_overlay("Hud")
	UiManager.hide_overlay("SessionSummary")

func _on_continue_button_mouse_entered() -> void:
	_play_hover()
	_scale_button(continue_button_animator, continue_button, Vector2(1.05, 1.05))

func _on_continue_button_mouse_exited() -> void:
	_scale_button(continue_button_animator, continue_button, Vector2(1.0, 1.0))
