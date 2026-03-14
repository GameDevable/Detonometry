extends Control
@onready var round_earnings_label: Label = $BackgroundPanel/ContentMargins/Content/RoundNumbers/RoundEarningsLabel
@onready var total_earnings_label: Label = $BackgroundPanel/ContentMargins/Content/RoundNumbers/TotalEarningsLabel
@onready var cluster_label: Label = $BackgroundPanel/ContentMargins/Content/RoundNumbers/ClusterLabel
@onready var total_shapes_label: Label = $BackgroundPanel/ContentMargins/Content/RoundNumbers/TotalShapesLabel
@onready var bombs_placed_label: Label = $BackgroundPanel/ContentMargins/Content/RoundNumbers/BombsPlacedLabel

@onready var upgrade_hub_button: Button = $BackgroundPanel/ContentMargins/Buttons/UpgradeHubButton
@onready var upgrade_button_animator: UiEffectComponent = $BackgroundPanel/ContentMargins/Buttons/UpgradeHubButton/UpgradeButtonAnimator

@onready var continue_button: Button = $BackgroundPanel/ContentMargins/Buttons/ContinueButton
@onready var continue_button_animator: UiEffectComponent = $BackgroundPanel/ContentMargins/Buttons/ContinueButton/ContinueButtonAnimator


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.session_ended.connect(_on_session_ended)


func _handle_shown() -> void:
	UiManager.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON)


func _on_session_ended(data: Array[int]) -> void:
	round_earnings_label.text = "Round Earnings: " + str(data[0])
	total_earnings_label.text = "Total Earnings: " + str(data[1])
	bombs_placed_label.text = "Bombs Placed: " + str(data[2])
	total_shapes_label.text = "Total Shapes Destroyed: " + str(data[3])
	cluster_label.text = "Max Cluster: " + str(data[4])


func _on_upgrade_hub_button_pressed() -> void:
	EffectManager.play_sfx(Constants.BUTTON_CLICK_SOUND, 0.0, Constants.BUTTON_CLICK_VOLUME, Constants.BUTTON_CLICK_PITCH)
	UiManager.transition_to("UpgradeHub")
	await get_tree().create_timer(0.01).timeout
	UiManager.hide_overlay("SessionSummary")


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
	await get_tree().create_timer(0.01).timeout
	UiManager.show_overlay("Hud")
	UiManager.hide_overlay("SessionSummary")


func _on_continue_button_mouse_entered() -> void:
	var base_pitch: float = 1.0
	EffectManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)
	var end_scale: Vector2 = Vector2(1.1, 1.1)
	continue_button_animator.scale_ui(continue_button.scale, end_scale, Tween.TRANS_EXPO)


func _on_continue_button_mouse_exited() -> void:
	var end_scale: Vector2 = Vector2(1.0, 1.0)
	continue_button_animator.scale_ui(continue_button.scale, end_scale, Tween.TRANS_EXPO)
