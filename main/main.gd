extends Node
const MYSTERY = preload("uid://cdbe4cwxplk83")
const SUSPENSE_PULSE = preload("uid://gwupsm1qifj7")
const SUSPENSE_PULSE_TENSE = preload("uid://csl7fpgep6fag")
const SUSPENSE_TENSION = preload("uid://bc8pxvib31qyn")
const DARK_AMBIENT_MUSIC = preload("uid://cbh6a3ltatnma")
const SOLITUDE_DARK_AMBIENT_MUSIC = preload("uid://dl3t2dd0ha6gg")
func _ready() -> void:
	SaveManager.load_game()
	UiManager.set_up_ui(get_child(1))
	UiManager.show_overlay("Hud")
	
	UiManager.swap_menu("SettingsMenu")
	EffectManager.set_music_node($Music)
	EffectManager.set_audio_contianer($AudioHolder)
	EffectManager.set_particle_container($ParticleHolder)
	EffectManager.start_music(DARK_AMBIENT_MUSIC)
	Console.add_command("delete_save", SaveManager.reset_file)
	SignalManager.session_restarted.connect(_on_session_restarted)
	Input.set_custom_mouse_cursor(Constants.OPEN_HAND_CURSOR_ICON, Input.CURSOR_ARROW, Constants.OPEN_HAND_CURSOR_ICON.get_size() / 2)
	Input.set_custom_mouse_cursor(Constants.POINTER_HAND_CURSOR_ICON, Input.CURSOR_POINTING_HAND)


func _on_session_restarted() -> void:
	for child in $AudioHolder.get_children():
		child.queue_free()
	for child in $ParticleHolder.get_children():
		child.queue_free()
