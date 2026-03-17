extends Node
@onready var ui_canvas_layer: CanvasLayer = $UiCanvasLayer
@onready var mouse_layer: CanvasLayer = $MouseLayer
@onready var world: World = $World
const DEBRIS_PARTICLES = preload("uid://cwvgah0m7wfey")
const BLAST_PARTICLE = preload("uid://db1td87mfq0rt")
const EXPLOSION_PARTICLES = preload("uid://cc8hnlp15466b")
const SPARK_PARTICLES = preload("uid://jjxpg78gpkdj")
const BREAK_PARTICLES = preload("uid://bj1jgl6835u7y")

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
	_load_particles()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	Engine.time_scale = 1.0


func _on_session_restarted() -> void:
	for child in $AudioHolder.get_children():
		child.queue_free()
	for child in $ParticleHolder.get_children():
		child.queue_free()


func _load_particles() -> void:
	EffectManager.spawn_particles(SPARK_PARTICLES, Vector2.ZERO)
	EffectManager.spawn_particles(DEBRIS_PARTICLES, Vector2.ZERO + Vector2(0, 20))
	EffectManager.spawn_particles(EXPLOSION_PARTICLES, Vector2.ZERO)
	EffectManager.spawn_particles(BLAST_PARTICLE, Vector2.ZERO)
	EffectManager.spawn_particles(BREAK_PARTICLES, Vector2.ZERO)
