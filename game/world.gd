class_name World
extends Node2D 
const BOMB_PLACE_SOUND1 = preload("res://bomb/assets/audio/bomb_place_sound1.ogg")
const BOMB_PLACE_SOUND2 = preload("res://bomb/assets/audio/bomb_place_sound2.ogg")
const CRATE_BREAK = preload("uid://bggl4xban0c58")
const CLUSTER_BROKE_PARTICLES = preload("uid://fch54yu8d7av")
const FUSE_LIGHT_SOUND_1 = preload("uid://bbevtgy7k6s4t")
const FUSE_LIGHT_SOUND_2 = preload("uid://wuqqihnsq5jp")

var held_bomb: Bomb = null
var can_create_bomb: bool = true
var timer_over: bool = false
var time_since_bomb_creation: float = 0.0
var current_run_gain: int = 0
var total_shapes_destroyed: int = 0
var shape_det_val: int = 1
var cluster_det_mult_val: float = 1.65



@onready var bomb_container: Node2D = $BombContainer
@onready var place_delay_timer: Timer = $PlaceDelayTimer
@onready var session_timer: Timer = $SessionTimer
@onready var camera: Camera2D = $Camera


func _ready() -> void:
	Console.add_command("set_points", _command_set_points, ["amount"], 1)
	Console.add_command("quit_session", _command_quit_session)
	_connect_signals()



func _process(delta: float) -> void:
	if not place_delay_timer.is_stopped():
		SignalManager.place_delay_timer_changed.emit(snapped(place_delay_timer.time_left, 0.1))
	if held_bomb:
		time_since_bomb_creation += delta
	if not session_timer.is_stopped() and not timer_over:
		SignalManager.session_timer_updated.emit(session_timer.time_left)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_position: Vector2 = get_global_mouse_position()
		# The bomb will be created when the bomb_action is pressed
		if Input.is_action_just_pressed("bomb_place_action") and not held_bomb:
			if can_create_bomb or (GameManager.in_frenzy and not can_create_bomb):
				held_bomb = create_bomb(mouse_position)
				can_create_bomb = false
			else:
				SignalManager.unsuccessful_bomb_place.emit()
		# The bomb will be placed when the bomb_action is released
		if Input.is_action_just_released("bomb_place_action") and held_bomb:
			place_bomb()
			time_since_bomb_creation = 0.0
			if not GameManager.in_frenzy:
				place_delay_timer.start(StatManager.get_bomb_stat("place_delay"))
			else:
				place_delay_timer.start(0.4)
			SignalManager.bomb_placed.emit()
	elif event is InputEventMouseMotion:
		if held_bomb:
			held_bomb.position = get_global_mouse_position()


func handle_entered() -> void:
	SignalManager.session_timer_updated.emit(StatManager.get_session_stat("session_time"))
	session_timer.stop()
	get_tree().paused = false
	await get_tree().create_timer(1.5).timeout
	session_timer.start(StatManager.get_session_stat("session_time"))

func save() -> Dictionary:
	return {
		Constants.POINTS_SAVE_KEY: GameManager.total_points,
		Constants.MAX_SESSION_POINTS_SAVE_KEY: GameManager.max_session_points,
		Constants.MAX_SESSION_SHAPES_DESTROYED_SAVE_KEY: GameManager.max_session_shapes_destroyed,
		Constants.MAX_LARGEST_CLUSTER_SAVE_KEY: GameManager.max_largest_cluster,
		Constants.MAX_HIGHEST_BOMB_PROFIT_SAVE_KEY: GameManager.max_highest_bomb_profit,
		"session_number" : GameManager.session_number
	}


func load_save_data(data: Dictionary) -> void:
	GameManager.total_points = data[Constants.POINTS_SAVE_KEY]

	GameManager.max_session_points = data[Constants.MAX_SESSION_POINTS_SAVE_KEY]
	GameManager.max_session_shapes_destroyed = data[Constants.MAX_SESSION_SHAPES_DESTROYED_SAVE_KEY]
	GameManager.max_largest_cluster = data[Constants.MAX_LARGEST_CLUSTER_SAVE_KEY]
	GameManager.max_highest_bomb_profit = data[Constants.MAX_HIGHEST_BOMB_PROFIT_SAVE_KEY]
	GameManager.session_number = data["session_number"]
	SignalManager.points_changed.emit(GameManager.total_points)


# Initializes an bomb at a certain position (usually the mouse position)
func create_bomb(spawn_position: Vector2, in_hand: bool = true) -> Bomb:
	var packed_bomb_scene: PackedScene = load(Constants.BOMB_SCENE_PATH)
	var bomb_instance: Bomb = packed_bomb_scene.instantiate()
	bomb_instance.position = spawn_position
	# I get a bunch of errors if it is not deferred
	bomb_container.call_deferred("add_child", bomb_instance)
	
	if in_hand:
		SignalManager.bomb_created.emit()
	return bomb_instance

 
func place_bomb() -> void:
	if held_bomb:
		var vol1 = -2.0
		var vol2 = -3.0
		EffectManager.play_sfx(BOMB_PLACE_SOUND1, 0.12, vol1, 0.92)
		EffectManager.play_sfx(BOMB_PLACE_SOUND2, 0, vol2, 0.93)
		
		held_bomb.call_deferred("handle_placed")
		# This effectively "places" the bomb by not resetting its position to the mouse
		held_bomb = null 


func spawn_bomb(bomb_position: Vector2, in_hand: bool = true):
	var bomb_instance: Bomb = create_bomb(bomb_position, in_hand)
	bomb_instance.call_deferred("handle_placed")


func _connect_signals() -> void:
	SignalManager.bomb_detonated.connect(_on_bomb_detonated)
	SignalManager.upgrade_purchased.connect(func(upgrade: Upgrade) -> void:
		_set_points(GameManager.total_points - upgrade.get_previous_price())
	)
	SignalManager.session_restarted.connect(_on_session_restarted)
	SignalManager.spawn_bomb.connect(func(spawn_position: Vector2) -> void:
		spawn_bomb(spawn_position, false)
		)
	SignalManager.shape_broken.connect(func(shape: Shape, by_bomb: bool) -> void:
		if not by_bomb:
			_handle_shape_broken(shape)
		)
	SignalManager.frenzy_ended.connect(func() -> void:
		if timer_over:
			_on_session_timer_timeout()
	)


func _command_set_points(amount: String) -> void:
	_set_points(amount.to_int())


func _command_quit_session() -> void:
	session_timer.wait_time = 30
	_on_session_timer_timeout()


func _set_points(amount: int) -> void:
	GameManager.total_points = amount
	SignalManager.points_changed.emit(GameManager.total_points)


func _handle_shape_broken(shape_instance: Shape, total_external_multiplier: float = 1.0, total_external_bonus: float = 0.0, in_cluster: bool = false) -> void:
	var shape_value: int = ceil((shape_instance.get_value() + total_external_bonus) * total_external_multiplier)
	current_run_gain += shape_value
	SignalManager.session_points_changed.emit(int(current_run_gain))
	
	GameManager.session_data[0] = current_run_gain
	#_set_points(GameManager.total_points + shape_value)
	var text = "+$" + str(shape_value)
	
	total_shapes_destroyed += 1
	GameManager.session_data[1] = total_shapes_destroyed
	var volume: float = -21
	EffectManager.play_sfx(CRATE_BREAK, 0.0, volume, 0.6, true, Vector2(0.55, 0.6))
	if not in_cluster:
		var time: float = 1.15
		EffectManager.spawn_floating_text(text ,shape_instance.position + Vector2(0, -10.0), time)
		# We want cluster to handle adding to the idx 
		GameManager.detonation_idx_value += shape_det_val
		SignalManager.detonation_idx_value_changed.emit(GameManager.detonation_idx_value)
		if GameManager.session_data[3] < shape_value:
			GameManager.session_data[3] = shape_value
	shape_instance.queue_free()


func _handle_cluster_broken(shapes_broken: Array[Node2D], total_external_bonus: float, total_external_multiplier) -> void:
	var total: int = 0
	var bunch_center_pos: Vector2 = Vector2.ZERO
	var position_running_total: Vector2 = Vector2.ZERO
	var volume: float = -19 
	
	for shape in shapes_broken:
		position_running_total += shape.global_position
		var shape_value: int = ceil((shape.get_value() + total_external_bonus) * total_external_multiplier)
		total += shape_value
	var highest_bomb_profit: int = GameManager.session_data[3]
	if highest_bomb_profit < total:
		GameManager.session_data[3] = total
	
	GameManager.detonation_idx_value += shape_det_val * shapes_broken.size() * cluster_det_mult_val
	SignalManager.detonation_idx_value_changed.emit(GameManager.detonation_idx_value)
	camera.shake_component.shake(7, 1.0)
	bunch_center_pos = position_running_total / shapes_broken.size()
	
	var text: String = "+$" + str(total)
	var time: float = 1.5
	var text_scale: Vector2 = Vector2(1.0, 1.0) * (1 + (float(shapes_broken.size()) / 8))
	EffectManager.spawn_floating_text(text, bunch_center_pos, time, text_scale)
	
	#EffectManager.play_sfx(MONEY_GAINED_SOUND, 0.0, -18, 0.55)
	for i in range(int(shapes_broken.size() / 2)):
		EffectManager.spawn_particles(CLUSTER_BROKE_PARTICLES, bunch_center_pos, 0.1)
		
	for i in range(shapes_broken.size()):
		await get_tree().create_timer(randf_range(0.005, 0.007)).timeout
		EffectManager.play_sfx(CRATE_BREAK, 0.0, volume, 0.6, true, Vector2(0.57, 0.6))
	

func _on_bomb_detonated(shapes_broken: Array[Node2D]) -> void:
	var total_external_multiplier: float = 1.0
	var total_external_bonus: float = 0.0
	
	var in_cluster: bool = false
	total_external_multiplier *= _get_cluster_multiplier(shapes_broken.size())
	total_external_bonus += _get_cluster_bonus(shapes_broken.size())
		 
	if shapes_broken.size() > 1:
		in_cluster = true
		_handle_cluster_broken(shapes_broken, total_external_bonus, total_external_multiplier)
	
	# Destroys all of the shapes
	for shape in shapes_broken:
		if is_instance_valid(shape) and shape is Shape:
			_handle_shape_broken(shape, total_external_multiplier, total_external_bonus, in_cluster) 
		else:
			print("Not Valid")


func _get_cluster_multiplier(cluster_size: int) -> float:
	var largest_cluster_size: int = GameManager.session_data[2]
	
	if largest_cluster_size < cluster_size and cluster_size > 1:
		GameManager.session_data[2] = cluster_size
	
	
	if cluster_size >= StatManager.get_multiplier_stat("cluster_threshold"):
		return StatManager.get_multiplier_stat("cluster_multiplier")
	return 1.0


func _get_cluster_bonus(cluster_size: int) -> float:
	var threshold: int = int(StatManager.multiplier_stats["cluster_threshold"])
	if cluster_size >= threshold:
		var amount_of_shapes_over: int = cluster_size - threshold
		
		return amount_of_shapes_over * StatManager.multiplier_stats["cluster_exceed_bonus"]
	return 0.0


func _on_place_delay_timer_timeout() -> void:
	place_delay_timer.stop()
	SignalManager.delay_timer_out.emit()
	can_create_bomb = true


func _on_session_timer_timeout() -> void:
	timer_over = true
	if GameManager.in_frenzy:
		return
	session_timer.stop()
	if bomb_container.get_child_count() > 0:
		await bomb_container.emptied
		await get_tree().create_timer(0.5).timeout
	#await get_tree().create_timer(0.5).timeout
	place_delay_timer.stop()
	# Handles cursor issues
	UiManager.set_progress_visible(false)
	UiManager.set_mouse_cursor_visible(true)
	UiManager.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON)
	
	#UiManager.transition_to("UpgradeHub")
	SaveManager.save_game()
	UiManager.hide_overlay("Hud")
	await get_tree().create_timer(0.6).timeout
	UiManager.show_overlay("SessionSummary")


func _on_session_restarted() -> void:
	can_create_bomb = true
	timer_over = false
	time_since_bomb_creation = 0.0
	held_bomb = null
	current_run_gain = 0
	total_shapes_destroyed = 0
	GameManager.detonation_idx_value = 0
	SignalManager.detonation_idx_value_changed.emit(GameManager.detonation_idx_value) 
	place_delay_timer.stop()
	session_timer.start(StatManager.get_session_stat("session_time"))
	GameManager.session_data = [0, 0, 0, 0]
	for bomb in bomb_container.get_children():
		bomb.queue_free()
