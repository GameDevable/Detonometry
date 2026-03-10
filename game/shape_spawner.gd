extends Node2D
var spawn_time_passed: float = 0.0
var despawn_time_passed: float = 0.0

var shape_type_lookup: Dictionary[Enums.ShapeType, String] = {
	Enums.ShapeType.TRIANGLE : "triangle",
	Enums.ShapeType.SQUARE : "square",
	Enums.ShapeType.PENTAGON : "pentagon",
	Enums.ShapeType.HEXAGON : "hexagon",
	Enums.ShapeType.CIRCLE : "circle",
}


func _ready() -> void:
	SignalManager.spawn_shape_request.connect(_on_spawn_shape_requested)
	SignalManager.spawn_shape_bunch_request.connect(_on_spawn_shape_bunch_requested)
	SignalManager.spawn_sierpinski_triangles.connect(_spawn_sierpinski_subtriangles)
	SignalManager.session_restarted.connect(_on_session_restarted)


func _process(delta: float) -> void:
	_handle_shape_auto_spawn(delta)
	#_handle_shape_auto_despawn(delta)


func spawn_shape(spawn_position: Vector2, shape_type: Enums.ShapeType, modifiers: Array[Enums.ShapeModifiers] = [], include_random_modifiers: bool = true) -> Shape:
	# Initializes the actual shape object
	var packed_shape_scene: PackedScene = load(Constants.SHAPE_SCENE_PATH)
	var shape_instance: Shape = packed_shape_scene.instantiate()
	shape_instance.position = spawn_position
	# Initializes the data for the desired shape (based off of the name)
	var shape_data: ShapeData = load(Constants.SHAPE_RESOURCE_PATH_START + shape_type_lookup[shape_type] + Constants.SHAPE_RESOURCE_PATH_END).duplicate()
	
	# Sets the shape data variable
	shape_data.shape_type = shape_type
	
	# Sets all the shape variables
	shape_instance.shape_data = shape_data
	shape_instance.speed = _choose_random_speed()
	shape_instance.move_direction = _choose_random_direction()
	shape_instance.base_speed = shape_instance.speed
	if modifiers == [] and include_random_modifiers:
		_add_modifiers(shape_instance)
	else:
		shape_instance.shape_modifiers = modifiers
	# Flushing queries issue
	call_deferred("add_child", shape_instance)
	await shape_instance.tree_entered
	return shape_instance


func spawn_shape_bunch(amount: int, spawn_positions: Array[Vector2], shape_types: Array[Enums.ShapeType], modifiers: Array[Array], include_random_modifiers: bool = true) -> Array[Shape]:
	var shapes: Array[Shape] = []
	for i in range(amount):
		var shape_modifiers: Array[Enums.ShapeModifiers]= []
		if i < modifiers.size():
			for m in modifiers[i]:
				shape_modifiers.append(m as Enums.ShapeModifiers)
		shapes.append(await spawn_shape(spawn_positions[i], shape_types[i], shape_modifiers, include_random_modifiers))
	return shapes


func _spawn_sierpinski_subtriangles(triangle_position: Vector2, modifier_arrays_array: Array[Array]) -> void:
	var sub_triangle_positions: Array[Vector2] = [triangle_position + Vector2(0, -60), triangle_position + Vector2(-60, 60), triangle_position + Vector2(60, 60)]
	var type_array: Array[Enums.ShapeType] = [Enums.ShapeType.TRIANGLE, Enums.ShapeType.TRIANGLE, Enums.ShapeType.TRIANGLE]
		
	var shapes: Array[Shape] = await spawn_shape_bunch(3, sub_triangle_positions, type_array, modifier_arrays_array, false)
	# Speed
	const sub_triangle_speed: int = int((Constants.MIN_SHAPE_SPEED + Constants.MAX_SHAPE_SPEED) / 2.0)
	var speed_array: Array[int] = [sub_triangle_speed, sub_triangle_speed, sub_triangle_speed]
		
	# Directions
	var top_triangle_direction: Vector2 = Vector2(0, -1)
	var left_triangle_direction: Vector2 = Vector2(-1, 0)
	var right_triangle_direction: Vector2 = Vector2(1, 0)
	var direction_array: Array[Vector2] = [top_triangle_direction, left_triangle_direction, right_triangle_direction]
	# Overrrides values
	for i in range(shapes.size()):
		shapes[i].speed = speed_array[i]
		shapes[i].base_speed = speed_array[i]
		shapes[i].move_direction = direction_array[i]
		shapes[i].scale = Vector2(0.9, 0.9)


func _handle_shape_auto_spawn(delta: float) -> void:
	spawn_time_passed += delta
	var world_spawn_bounds: Array[int] = [-600, 600, -300, 300]
	if spawn_time_passed >= StatManager.get_shape_spawn_stat("spawn_time"): 
		spawn_time_passed = 0.0
		# If the max amount of shapes has not been reached, we spawn a new one.
		if not get_child_count() < StatManager.get_shape_spawn_stat("spawn_limit"):
			return
			
		var bunch_spawn_roll: float = randi_range(0, 100)
		if bunch_spawn_roll <= StatManager.get_shape_spawn_stat("bunch_spawn_chance"):
			_handle_auto_bunch_spawn(world_spawn_bounds)
		else: 
			# Order: left, right, top, bottom
			var shape_position: Vector2 = _choose_random_pos(world_spawn_bounds)
			var chosen_shape_type: Enums.ShapeType = _choose_random_shape_type()
			spawn_shape(shape_position, chosen_shape_type)


func _handle_auto_bunch_spawn(world_spawn_bounds: Array[int]) -> void:
	var shape_position: Vector2 = _choose_random_pos(world_spawn_bounds)
	var shape_spawn_bunch_number: int = int(StatManager.get_shape_spawn_stat("bunch_spawn_number"))
	var spawn_positions: Array[Vector2] = []
	var shape_types: Array[Enums.ShapeType] = []
	# Spawns x amount of shapes, setting all the datas for each
	for i in range(shape_spawn_bunch_number):
		var offset_bounds: Array[int] = [-40, 40, -40, 40]
		var shape_position_offset: Vector2 =_choose_random_pos(offset_bounds)
		var chosen_shape_type: Enums.ShapeType = _choose_random_shape_type()
		shape_types.append(chosen_shape_type)
		spawn_positions.append(shape_position + shape_position_offset)
	spawn_shape_bunch(shape_spawn_bunch_number, spawn_positions, shape_types, [])


# Generic weighted table total function
func _calc_weighted_table_total(weighted_table: Dictionary) -> float:
	var total: float = 0.0
	for value in weighted_table.values():
		total += value
	return total


func _add_modifiers(shape: Shape) -> void:
	var modifiers: Array[Enums.ShapeModifiers] = []
	for modifier_type in Enums.ShapeModifiers.values():
		var shape_name: String = Enums.ShapeType.keys()[shape.shape_data.shape_type].to_lower()
		var modifier_name: String = Enums.ShapeModifiers.keys()[modifier_type].to_lower()
		if shape_name != "triangle" and "sierpinski" in modifier_name: 
			return
		var modifier_chance_stat_name: String = modifier_name + "_" + shape_name + "_chance"
		if _should_add_modifier(StatManager.get_special_modifier_stat(modifier_chance_stat_name)):
			modifiers.append(modifier_type)
	shape.shape_modifiers = modifiers


func _should_add_modifier(modifier_chance: float) -> bool:
	var chance_roll: int = randi_range(0, 100)
	if modifier_chance <= 0:
		return false
	return chance_roll <= modifier_chance 


# Chooses a random shape type based off of a weighted table
func _choose_random_shape_type() -> Enums.ShapeType:
	var shape_type_weights: Dictionary[String, float] = StatManager.get_shape_type_weights()
	var weight_roll: float = randf() * _calc_weighted_table_total(shape_type_weights)
	# Goes through the weights to eventually choose the type
	for shape_type in shape_type_weights.keys():
		weight_roll -= shape_type_weights[shape_type]
		
		if weight_roll <= 0.0: return _convert_variable_name_to_type(shape_type)
	# Fall back
	print("Fallback")
	return Enums.ShapeType.TRIANGLE


func _choose_random_pos(spawn_position_bounds: Array[int]) -> Vector2:
	var left: int = spawn_position_bounds[0]
	var right: int = spawn_position_bounds[1]
	var top: int = spawn_position_bounds[2]
	var bottom: int = spawn_position_bounds[3]
	var viewport_size: Vector2 = get_viewport_rect().size
	# Makes sure that the bounds are not outside the viewport
	
	left   = clamp(left, -viewport_size.x / 2, 0)
	right  = clamp(right, 0, viewport_size.x / 2)
	top    = clamp(top, -viewport_size.y / 2, 0)
	bottom = clamp(bottom, 0, viewport_size.y / 2)
	
	var x: float = randf_range(left, right)
	var y: float = randf_range(bottom, top)
	# Snaps the position to a grid
	var rand_position: Vector2 = Vector2(x, y).snapped(Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE))
	return rand_position 


func _choose_random_direction() -> Vector2:
	return Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()


func _choose_random_speed() -> int:
	return randi_range(Constants.MIN_SHAPE_SPEED ,Constants.MAX_SHAPE_SPEED)


func _convert_variable_name_to_type(var_name: String) -> Enums.ShapeType:
	if "triangle" in var_name:
		return Enums.ShapeType.TRIANGLE
	elif "sqaure" in var_name:
		return Enums.ShapeType.SQUARE
	elif "pentagon" in var_name:
		return Enums.ShapeType.PENTAGON
	else:
		return Enums.ShapeType.CIRCLE


func _on_session_restarted() -> void:
	for child in get_children():
		child.queue_free()
	spawn_time_passed = 0.0
	despawn_time_passed = 0.0


func _on_spawn_shape_requested(spawn_position: Vector2, shape_type: Enums.ShapeType, modifiers: Array[Enums.ShapeModifiers]) -> void:
	spawn_shape(spawn_position, shape_type, modifiers)
 

func _on_spawn_shape_bunch_requested(amount: int, spawn_positions: Array[Vector2], shape_types: Array[Enums.ShapeType], modifier_array: Array[Array]) -> void:
	spawn_shape_bunch(amount, spawn_positions, shape_types, modifier_array)
