extends Node


func _ready() -> void:
	SaveManager.load_game()
	UiManager.set_up_ui(get_child(1))
	EffectManager.set_music_node($Music)
	EffectManager.set_audio_contianer($AudioHolder)
	EffectManager.set_particle_container($ParticleHolder)
	UiManager.swap_menu("MainMenu")
	EffectManager.start_music(Constants.GAME_MUSIC)
	Console.add_command("delete_save", SaveManager.reset_file)
	SignalManager.session_restarted.connect(_on_session_restarted)
	Input.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON, Input.CURSOR_POINTING_HAND)


func _on_session_restarted() -> void:
	for child in $AudioHolder.get_children():
		child.queue_free()
	for child in $ParticleHolder.get_children():
		child.queue_free()
