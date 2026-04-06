extends Control

var total_multiplier: float = 1.0

@onready var money_earned_value_label: Label = $ContentBackground/ContentMargins/HBoxContainer/DataMargins/DataContainer/MoneyEarnedValueLabel
@onready var shapes_destroyed_value_label: Label = $ContentBackground/ContentMargins/HBoxContainer/DataMargins/DataContainer/ShapesDestroyedValueLabel
@onready var largest_cluster_value_labels: Label = $ContentBackground/ContentMargins/HBoxContainer/DataMargins/DataContainer/LargestClusterValueLabels
@onready var highest_bomb_profit_value_label: Label = $ContentBackground/ContentMargins/HBoxContainer/DataMargins/DataContainer/HighestBombProfitValueLabel
@onready var total_money_value_label: Label = $ContentBackground/ContentMargins/HBoxContainer/DataMargins/DataContainer/TotalMoneyLabelMargins/TotalMoneyValueLabel
@onready var multiplier_value_label: Label = $ContentBackground/ContentMargins/HBoxContainer/DataMargins/DataContainer/MultiplierValueLabel

@onready var earned_record_notify: Panel = $ContentBackground/ContentMargins/HBoxContainer/RecordMargins/VBoxContainer/EarnedRecordNotify
@onready var destroyed_record_notify: Panel = $ContentBackground/ContentMargins/HBoxContainer/RecordMargins/VBoxContainer/DestroyedRecordNotify
@onready var cluster_record_notify: Panel = $ContentBackground/ContentMargins/HBoxContainer/RecordMargins/VBoxContainer/ClusterRecordNotify
@onready var profit_record_notify: Panel = $ContentBackground/ContentMargins/HBoxContainer/RecordMargins/VBoxContainer/ProfitRecordNotify


@onready var upgrade_hub_button: Button = $ContentBackground/Buttons/UpgradeHubButton
@onready var upgrade_button_animator: UiEffectComponent = $ContentBackground/Buttons/UpgradeHubButton/UpgradeButtonAnimator


@onready var ui_effect_component: UiEffectComponent = $ContentBackground/UiEffectComponent

@onready var content_background: Panel = $ContentBackground


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.session_ended.connect(_on_session_ended)


func handle_shown() -> void:
	_reset_labels()
	_reset_notifiers()
	UiManager.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON)
	content_background.scale = Vector2(0.01, 0.01)
	ui_effect_component.scale_ui(Vector2(0.01, 0.01), Vector2(1.0, 1.0), Tween.TRANS_EXPO)
	await ui_effect_component.tween.finished
	
	
	var session_earned: int = GameManager.session_data[0]
	var shapes_destroyed: int = GameManager.session_data[1]
	var largest_cluster_value: int = GameManager.session_data[2]
	var highest_bomb_profit: int = GameManager.session_data[3]
	
	var regular_tween_time: float = 0.4
	var record_time: float = 0.35
	await get_tree().create_timer(0.3).timeout
	
	tween_int(shapes_destroyed_value_label, 0, shapes_destroyed, regular_tween_time, false, false)
	tween_int(largest_cluster_value_labels, 0, largest_cluster_value, regular_tween_time, false, false)
	
	tween_int(money_earned_value_label, 0, session_earned, regular_tween_time, true, false)
	tween_int(highest_bomb_profit_value_label, 0, highest_bomb_profit, regular_tween_time, true, false)
	if highest_bomb_profit != 0 and shapes_destroyed != 0 and largest_cluster_value != 0:
		await get_tree().create_timer(0.5).timeout
	if highest_bomb_profit != 0:
		_check_and_show_record(Constants.MAX_SESSION_POINTS_SAVE_KEY, session_earned, earned_record_notify)
		await get_tree().create_timer(record_time).timeout
	if shapes_destroyed != 0:
		_check_and_show_record(Constants.MAX_SESSION_SHAPES_DESTROYED_SAVE_KEY, shapes_destroyed, destroyed_record_notify)
		await get_tree().create_timer(record_time).timeout
	if largest_cluster_value != 0:
		_check_and_show_record(Constants.MAX_LARGEST_CLUSTER_SAVE_KEY, largest_cluster_value, cluster_record_notify)
		await get_tree().create_timer(record_time).timeout
	if highest_bomb_profit != 0:
		_check_and_show_record(Constants.MAX_HIGHEST_BOMB_PROFIT_SAVE_KEY, highest_bomb_profit, profit_record_notify)
	var session_points: int = GameManager.session_data[0]
	GameManager.total_points += session_points * total_multiplier
	
	if total_multiplier > 1:
		await get_tree().create_timer(0.35).timeout
		
		tween_float(multiplier_value_label, 1.0, total_multiplier, 0.2, false, true)
	
	await get_tree().create_timer(0.25).timeout
	tween_int(total_money_value_label, 0, GameManager.total_points, regular_tween_time, true, false)
	

func _on_session_ended(_data: Array[int]) -> void:
	total_multiplier = 1.0
	_reset_labels()
	_reset_notifiers()


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


func _check_and_show_record(record_name: String, value: int, notify_node: Control) -> void:
	if GameManager.session_number == 0:
		GameManager.set(record_name, value)
		return
	if value <= GameManager.get(record_name):
		return
		
	GameManager.set(record_name, value)
	notify_node.visible = true
	total_multiplier += 0.2



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


func _reset_labels() -> void:
	money_earned_value_label.text = "$0"
	highest_bomb_profit_value_label.text = "$0"
	total_money_value_label.text = "$0"
	
	shapes_destroyed_value_label.text = "0"
	largest_cluster_value_labels.text = "0"
	multiplier_value_label.text = "x1.00"
	total_multiplier = 1.0


func _reset_notifiers() -> void:
	earned_record_notify.visible = false
	profit_record_notify.visible = false
	cluster_record_notify.visible = false
	destroyed_record_notify.visible = false


func _on_upgrade_hub_button_pressed() -> void:
	EffectManager.play_sfx(Constants.BUTTON_CLICK_SOUND, 0.0, Constants.BUTTON_CLICK_VOLUME, Constants.BUTTON_CLICK_PITCH)
	UiManager.transition_to("UpgradeHub")
	await get_tree().create_timer(0.01).timeout
	UiManager.hide_overlay("SessionSummary")
	GameManager.session_number += 1


func _on_upgrade_hub_button_mouse_entered() -> void:
	var base_pitch: float = 1.0
	EffectManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)
	var end_scale: Vector2 = Vector2(1.1, 1.1)
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
