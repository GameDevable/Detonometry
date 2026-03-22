extends Control

@onready var money_earned_value_label: Label = $ContentBackground/ContentMargins/HBoxContainer/DataContainer/MoneyEarnedMargins/MoneyEarnedValueLabel
@onready var shapes_destroyed_value_label: Label = $ContentBackground/ContentMargins/HBoxContainer/DataContainer/ShapesDestroyedValueLabel
@onready var largest_cluster_value_labels: Label = $ContentBackground/ContentMargins/HBoxContainer/DataContainer/LargestClusterValueLabels
@onready var cluster_mult_label: Label = $ContentBackground/ContentMargins/HBoxContainer/DataContainer/ClusterMultLabel
@onready var blast_mult_label: Label = $ContentBackground/ContentMargins/HBoxContainer/DataContainer/BlastMultLabel
@onready var total_money_value_label: Label = $ContentBackground/ContentMargins/HBoxContainer/DataContainer/TotalMoneyLabelMargins/TotalMoneyValueLabel

@onready var upgrade_hub_button: Button = $ContentBackground/Buttons/UpgradeHubButton
@onready var upgrade_button_animator: UiEffectComponent = $ContentBackground/Buttons/UpgradeHubButton/UpgradeButtonAnimator

@onready var continue_button: Button = $ContentBackground/Buttons/ContinueButton
@onready var continue_button_animator: UiEffectComponent = $ContentBackground/Buttons/ContinueButton/ContinueButtonAnimator

@onready var ui_effect_component: UiEffectComponent = $ContentBackground/UiEffectComponent

@onready var content_background: Panel = $ContentBackground


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.session_ended.connect(_on_session_ended)


func handle_shown() -> void:
	UiManager.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON)
	content_background.scale = Vector2(0.01, 0.01)
	ui_effect_component.scale_ui(Vector2(0.01, 0.01), Vector2(1.0, 1.0), Tween.TRANS_EXPO)
	var bombs_placed: int = GameManager.session_data[1]
	var shapes_destroyed: int = GameManager.session_data[2]
	var do_good_multiplier: float = 1.0 + (shapes_destroyed - bombs_placed) / 8.0
	
	var cluster_multiplier: float = 1.0 + GameManager.session_data[3] / 10.0
	
	var multiplier_tween_time: float = 0.2
	var regular_tween_time: float = 0.4
	await get_tree().create_timer(1.2).timeout
	tween_float(cluster_mult_label, 0.0, cluster_multiplier, multiplier_tween_time, false, true)
	tween_float(blast_mult_label, 0.0, do_good_multiplier, multiplier_tween_time, false, true)
	
	tween_int(shapes_destroyed_value_label, 0, shapes_destroyed, regular_tween_time, false, false)
	tween_int(largest_cluster_value_labels, 0, GameManager.session_data[3], regular_tween_time, false, false)
	
	tween_int(money_earned_value_label, 0, GameManager.session_data[0], regular_tween_time, true, false)
	tween_int(total_money_value_label, 0, GameManager.total_points, regular_tween_time, true, false)


func _on_session_ended(_data: Array[int]) -> void:
	
	
	var bombs_placed: int = GameManager.session_data[1]
	var shapes_destroyed: int = GameManager.session_data[2]
	
	var do_good_multiplier: float = 1.0 + (shapes_destroyed - bombs_placed) / 8.0
	var cluster_multiplier: float = 1.0 + GameManager.session_data[3] / 10.0
	var session_points: int = GameManager.session_data[0]
	GameManager.total_points += (session_points * int(do_good_multiplier * cluster_multiplier))
	
	reset_labels()


func tween_float(label: Label, start: float, end: float, duration: float, is_money: bool, is_multiplier: bool) -> void:
	var tween = create_tween()
	tween.tween_method(
		func(value): label.text = _format_float(value, is_money, is_multiplier),
		start,
		end,
		duration
	)


func tween_int(label: Label, start: int, end: int, duration: float, is_money: bool, is_multiplier: bool) -> void:
	var tween = create_tween()
	tween.tween_method(
		func(value): label.text = _format_int(int(round(value)), is_money, is_multiplier),
		start,
		end,
		duration
	)


func _format_float(value: float, is_money: bool, is_multiplier: bool) -> String:
	if is_money:
		return "$%.2f" % value
	if is_multiplier:
		return "x%.2f" % value
	return "%.2f" % value


func _format_int(value: int, is_money: bool, is_multiplier: bool) -> String:
	if is_money:
		return "$%d" % value
	if is_multiplier:
		return "x%d" % value
	return "%d" % value


func reset_labels() -> void:
	money_earned_value_label.text = "$0"
	total_money_value_label.text = "$0"
	
	shapes_destroyed_value_label.text = "0"
	largest_cluster_value_labels.text = "0"
	
	cluster_mult_label.text = "x0.00"
	blast_mult_label.text = "x0.00"


func _on_upgrade_hub_button_pressed() -> void:
	EffectManager.play_sfx(Constants.BUTTON_CLICK_SOUND, 0.0, Constants.BUTTON_CLICK_VOLUME, Constants.BUTTON_CLICK_PITCH)
	UiManager.transition_to("UpgradeHub")
	await get_tree().create_timer(0.01).timeout
	UiManager.hide_overlay("SessionSummary")


func _on_upgrade_hub_button_mouse_entered() -> void:
	var base_pitch: float = 1.0
	EffectManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)
	var end_scale: Vector2 = Vector2(1.05, 1.05)
	upgrade_button_animator.scale_ui(upgrade_hub_button.scale, end_scale, Tween.TRANS_EXPO)


func _on_upgrade_hub_button_mouse_exited() -> void:
	var end_scale: Vector2 = Vector2(1.0, 1.0)
	upgrade_button_animator.scale_ui(upgrade_hub_button.scale, end_scale, Tween.TRANS_EXPO)


func _on_continue_button_pressed() -> void:
	UiManager.transition_to("None")
	EffectManager.play_sfx(Constants.BUTTON_CLICK_SOUND, 0.0, Constants.BUTTON_CLICK_VOLUME, Constants.BUTTON_CLICK_PITCH)
	await get_tree().create_timer(0.6).timeout
	UiManager.show_overlay("Hud")
	UiManager.hide_overlay("SessionSummary")


func _on_continue_button_mouse_entered() -> void:
	var base_pitch: float = 1.0
	EffectManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)
	var end_scale: Vector2 = Vector2(1.05, 1.05)
	continue_button_animator.scale_ui(continue_button.scale, end_scale, Tween.TRANS_EXPO)


func _on_continue_button_mouse_exited() -> void:
	var end_scale: Vector2 = Vector2(1.0, 1.0)
	continue_button_animator.scale_ui(continue_button.scale, end_scale, Tween.TRANS_EXPO)
