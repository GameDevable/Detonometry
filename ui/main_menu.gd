extends Control
@onready var new_game_button: Button = $NewGameButton
@onready var settings_button: Button = $SettingsButton
@onready var quit_button: Button = $QuitButton

@onready var game_button_animator: UiEffectComponent = $NewGameButton/GameButtonAnimator
@onready var settings_button_animator: UiEffectComponent = $SettingsButton/SettingsButtonAnimator
@onready var quit_button_animator: UiEffectComponent = $QuitButton/QuitButtonAnimator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_new_game_button_pressed() -> void:
	UiManager.transition_to("None")
	await get_tree().create_timer(0.5).timeout
	UiManager.show_overlay("Hud")


func _on_settings_button_pressed() -> void:
	UiManager.transition_to("SettingsMenu")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_new_game_button_mouse_entered() -> void:
	var end_scale: Vector2 = Vector2(1.1, 1.1)
	game_button_animator.scale_ui(new_game_button.scale, end_scale, Tween.TRANS_EXPO)


func _on_new_game_button_mouse_exited() -> void:
	var end_scale: Vector2 = Vector2(1.0, 1.0)
	game_button_animator.scale_ui(new_game_button.scale, end_scale, Tween.TRANS_EXPO)


func _on_settings_button_mouse_entered() -> void:
	var end_scale: Vector2 = Vector2(1.1, 1.1)
	settings_button_animator.scale_ui(settings_button.scale, end_scale, Tween.TRANS_EXPO)


func _on_settings_button_mouse_exited() -> void:
	var end_scale: Vector2 = Vector2(1.0, 1.0)
	settings_button_animator.scale_ui(settings_button.scale, end_scale, Tween.TRANS_EXPO)


func _on_quit_button_mouse_entered() -> void:
	var end_scale: Vector2 = Vector2(1.1, 1.1)
	quit_button_animator.scale_ui(quit_button.scale, end_scale, Tween.TRANS_EXPO)


func _on_quit_button_mouse_exited() -> void:
	var end_scale: Vector2 = Vector2(1.0, 1.0)
	quit_button_animator.scale_ui(quit_button.scale, end_scale, Tween.TRANS_EXPO)
