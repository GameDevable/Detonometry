class_name World
extends Node2D 
var held_bomb: Bomb = null
var can_create_bomb: bool = true
var time_since_bomb_creation: float = 0.0
var session_data: Array[int] = [0, 0, 0]
var total_points: int = 0
var current_run_gain: int = 0
const BOMB_PLACE_SOUND1 = preload("res://bomb/assets/audio/bomb_place_sound1.ogg")
const BOMB_PLACE_SOUND2 = preload("res://bomb/assets/audio/bomb_place_sound2.ogg")
@onready var bomb_container: Node2D = $BombContainer
@onready var place_delay_timer: Timer = $PlaceDelayTimer
@onready var session_timer: Timer = $SessionTimer

func _ready() -> void:
	Console.add_command("set_points", _command_set_points, ["amount"], 1)
	Console.add_command("quit_session", _command_quit_session)
	SignalManager.bomb_detonated.connect(_on_bomb_detonated)
	SignalManager.upgrade_purchased.connect(func(upgrade: Upgrade) -> void:
		_set_points(total_points - upgrade.get_previous_price())
	)
	SignalManager.session_restarted.connect(_on_session_restarted)


func _process(delta: float) -> void:
	if not place_delay_timer.is_stopped():
		SignalManager.place_delay_timer_changed.emit(snapped(place_delay_timer.time_left, 0.1))
	if held_bomb:
		time_since_bomb_creation += delta
	if not session_timer.is_stopped():
		SignalManager.session_timer_updated.emit(session_timer.time_left)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_position: Vector2 = get_global_mouse_position()
		# The bomb will be created when the bomb_action is pressed
		if Input.is_action_just_pressed("bomb_place_action") and not held_bomb:
			if can_create_bomb:
				held_bomb = create_bomb(mouse_position)
				can_create_bomb = false
			else:
				SignalManager.unsuccessful_bomb_place.emit()
		# The bomb will be placed when the bomb_action is released
		if Input.is_action_just_released("bomb_place_action") and held_bomb:
			place_bomb()
			time_since_bomb_creation = 0.0
			place_delay_timer.start(StatManager.get_bomb_stat("place_delay"))
			SignalManager.bomb_placed.emit()
	elif event is InputEventMouseMotion:
		if held_bomb:
			held_bomb.position = get_global_mouse_position()


func save() -> Dictionary:
	return {"points" : total_points}


func load_save_data(data: Dictionary) -> void:
	total_points = data["points"]
	SignalManager.points_changed.emit(total_points)


# Initializes an bomb at a certain position (usually the mouse position)
func create_bomb(spawn_position: Vector2) -> Bomb:
	var packed_bomb_scene: PackedScene = load(Constants.BOMB_SCENE_PATH)
	var bomb_instance: Bomb = packed_bomb_scene.instantiate()
	bomb_instance.position = spawn_position
	EffectManager.play_sfx(BOMB_PLACE_SOUND1, 0.0, -3.0, 1.75)
	# I get a bunch of errors if it is not deferred
	bomb_container.call_deferred("add_child", bomb_instance)
	SignalManager.bomb_created.emit()
	return bomb_instance

 
func place_bomb() -> void:
	if held_bomb:
		var vol1 = 2.0
		var vol2 = 1.0
		EffectManager.play_sfx(BOMB_PLACE_SOUND1, 0.12, vol1, 0.92)
		EffectManager.play_sfx(BOMB_PLACE_SOUND2, 0, vol2, 0.93)
		
		held_bomb.call_deferred("handle_placed")
		# This effectively "places" the bomb by not resetting its position to the mouse
		held_bomb = null 
		session_data[2] += 1


func spawn_floating_text(text: String, text_position: Vector2, text_color: Color, visible_time: float):
	var floating_text: Marker2D = load(Constants.FLOATING_TEXT_PATH).instantiate()
	var text_label: Label = floating_text.get_child(0)
	floating_text.exist_time = visible_time
	text_label.text = text
	floating_text.position = text_position
	text_label.add_theme_color_override("font_color", text_color)
	add_child(floating_text)
	await get_tree().create_timer(visible_time).timeout
	floating_text.queue_free()


func spawn_bomb(bomb_position: Vector2):
	var bomb_instance: Bomb = create_bomb(bomb_position)
	bomb_instance.handle_placed()


func _command_set_points(amount: String) -> void:
	_set_points(amount.to_int())


func _command_quit_session() -> void:
	session_timer.wait_time = 30
	_on_session_timer_timeout()


func _set_points(amount: int) -> void:
	total_points = amount
	session_data[1] = total_points
	SignalManager.points_changed.emit(total_points)


func _handle_shape_broken(shape_instance: Shape, total_external_multiplier: float = 1.0, total_external_bonus: float = 0.0) -> void:
	var shape_value: int = ceil((shape_instance.get_value() + total_external_bonus) * total_external_multiplier)
	current_run_gain += shape_value
	session_data[0] = current_run_gain
	_set_points(total_points + shape_value)
	var text = "+$" + str(shape_value)
	spawn_floating_text(text ,shape_instance.position + Vector2(0, -10.0), Color.GREEN, 1.15)
	shape_instance.queue_free()


func _on_bomb_detonated(shapes_broken: Array[Node2D]) -> void:
	var total_external_multiplier: float = 1.0
	var total_external_bonus: float = 0.0
	
	total_external_multiplier *= _get_cluster_multiplier(shapes_broken.size())
	total_external_bonus += _get_cluster_bonus(shapes_broken.size())
	
	for shape in shapes_broken:
		if is_instance_valid(shape) and shape is Shape:
			_handle_shape_broken(shape, total_external_multiplier, total_external_bonus) 
		else:
			print("Not Valid")


func _get_cluster_multiplier(cluster_size: int) -> float:
	if cluster_size >= StatManager.get_multiplier_stat("cluster_threshold"):
		return StatManager.get_multiplier_stat("cluster_multiplier")
	return 1.0


func _get_cluster_bonus(cluster_size: int) -> float:
	var threshold: int = int(StatManager.multiplier_stats["cluster_threshold"])
	if cluster_size >= threshold:
		var amount_of_shapes_over: int = threshold - cluster_size
		return amount_of_shapes_over * StatManager.multiplier_stats["cluster_exceed_bonus"]
	return 0.0


func _on_place_delay_timer_timeout() -> void:
	place_delay_timer.stop()
	can_create_bomb = true


func _on_session_timer_timeout() -> void:
	session_timer.stop()
	if bomb_container.get_child_count() > 0:
		await bomb_container.emptied
		await get_tree().create_timer(0.5).timeout
	UiManager.transition_to("UpgradeHub")
	UiManager.hide_overlay("Hud")
	SaveManager.save_game()


func _on_session_restarted() -> void:
	can_create_bomb = true
	time_since_bomb_creation = 0.0
	held_bomb = null
	can_create_bomb = true
	current_run_gain = 0
	place_delay_timer.stop()
	session_timer.start(StatManager.get_session_stat("session_time"))
	session_data = [0, 0, 0]
	for bomb in bomb_container.get_children():
		bomb.queue_free()
