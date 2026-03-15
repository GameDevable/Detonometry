extends Node
@onready var ui_canvas_layer: CanvasLayer = $UiCanvasLayer
@onready var mouse_layer: CanvasLayer = $MouseLayer
@onready var world: World = $World


func _ready() -> void:
	SaveManager.load_game()
	UiManager.set_up_ui(ui_canvas_layer, mouse_layer)
	UiManager.set_up_world(world)
	EffectManager.set_music_node($Music)
	EffectManager.set_audio_contianer($AudioHolder)
	EffectManager.set_particle_container($ParticleHolder)
	UiManager.swap_menu("MainMenu")
	EffectManager.start_music(Constants.GAME_MUSIC)
	Console.add_command("delete_save", SaveManager.reset_file)
	SignalManager.session_restarted.connect(_on_session_restarted)
	UiManager.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	Engine.time_scale = 1.0


func _on_session_restarted() -> void:
	for child in $AudioHolder.get_children():
		child.queue_free()
	for child in $ParticleHolder.get_children():
		child.queue_free()
