extends Node2D

var shape_type_lookup: Dictionary[Enums.ShapeType, String] = {
	Enums.ShapeType.TRIANGLE : "triangle",
	Enums.ShapeType.SQUARE : "square",
	Enums.ShapeType.PENTAGON : "pentagon",
	Enums.ShapeType.HEXAGON : "hexagon",
	Enums.ShapeType.CIRCLE : "circle",
}

var shape_containers: Dictionary[Enums.ShapeType, Node2D] = {}

const REINFORCED_COMPONENT = preload("uid://di7k4eb3imi33")
const LUCKY_COMPONENT = preload("uid://dh8j4i14eauhe")
const SIERPINSKIES_COMPONENT = preload("uid://bdacywg0y6sha")

const SHAPE_MODIFIER_COMPONENTS: Array[PackedScene] = [REINFORCED_COMPONENT, LUCKY_COMPONENT, SIERPINSKIES_COMPONENT]
func _ready() -> void:
	SignalManager.spawn_sierpinski_triangles.connect(_spawn_sierpinski_subtriangles)
	SignalManager.session_restarted.connect(func() -> void:
		for child in get_children():
			if child is Node2D:
				for shape in child.get_children():
					shape.queue_free()
		)
	shape_containers = {
		Enums.ShapeType.TRIANGLE: $Triangles,
		Enums.ShapeType.SQUARE: $Squares,
		Enums.ShapeType.CIRCLE: $Circles,
		Enums.ShapeType.PENTAGON: $Pentagons
	}
	_create_timer(Enums.ShapeType.TRIANGLE)
	_create_timer(Enums.ShapeType.SQUARE)
	_create_timer(Enums.ShapeType.CIRCLE)
	_create_timer(Enums.ShapeType.PENTAGON)


func spawn_shape(spawn_position: Vector2, shape_type: Enums.ShapeType, modifiers: Array[ShapeModifierComponent] = [], include_random_modifiers: bool = true) -> Shape:
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
	shape_instance.speed = randi_range(Constants.MIN_SHAPE_SPEED ,Constants.MAX_SHAPE_SPEED)
	shape_instance.move_direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	shape_instance.base_speed = shape_instance.speed
	if modifiers == [] and include_random_modifiers:
		_add_modifiers(shape_instance)
	else:
		for child in modifiers:
			shape_instance.add_child(child)
	# Flushing queries issue
	shape_containers[shape_type].call_deferred("add_child", shape_instance)
	await shape_instance.tree_entered
	return shape_instance


func spawn_shape_bunch(amount: int, spawn_positions: Array[Vector2], shape_types: Array[Enums.ShapeType], modifiers: Array[Array], include_random_modifiers: bool = true) -> Array[Shape]:
	var shapes: Array[Shape] = []
	for i in range(amount):
		var shape_modifiers: Array[ShapeModifierComponent]= []
		if i < modifiers.size():
			for modifier_component in modifiers[i]:
				shape_modifiers.append(modifier_component)
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
	var left_triangle_direction: Vector2 = Vector2(-1, 1)
	var right_triangle_direction: Vector2 = Vector2(1, 1)
	var direction_array: Array[Vector2] = [top_triangle_direction, left_triangle_direction, right_triangle_direction]
	# Overrrides values
	for i in range(shapes.size()):
		shapes[i].speed = speed_array[i]
		shapes[i].base_speed = speed_array[i]
		shapes[i].move_direction = direction_array[i]
		#shapes[i].scale = Vector2(0.9, 0.9)


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
	for packed_component in SHAPE_MODIFIER_COMPONENTS:
		var component: ShapeModifierComponent = packed_component.instantiate()
		var modifier_chance: float = StatManager.get_special_modifier_stat(component.modifier_weight_name)
		print(component.modifier_weight_name)
		print(modifier_chance)
		if _should_add_modifier(modifier_chance):
			if (component.is_specific_to_one_shape and shape.shape_data.shape_type == component.specific_shape) or not component.is_specific_to_one_shape:
				shape.add_child(component)


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


func _convert_variable_name_to_type(var_name: String) -> Enums.ShapeType:
	if "triangle" in var_name:
		return Enums.ShapeType.TRIANGLE
	elif "sqaure" in var_name:
		return Enums.ShapeType.SQUARE
	elif "pentagon" in var_name:
		return Enums.ShapeType.PENTAGON
	else:
		return Enums.ShapeType.CIRCLE


func _create_timer(type: Enums.ShapeType) -> void:
	var timer: Timer = Timer.new()
	timer.wait_time = StatManager.get_shape_spawn_stat(_get_spawn_rate_name(type))
	timer.timeout.connect(func(): _on_spawn_timer_timeout(type))
	add_child(timer)
	timer.start()

# Get the spawn limit name for a shape
func _get_spawn_limit_name(shape_type: Enums.ShapeType) -> String:
	var shape_name = str(Enums.ShapeType.keys()[shape_type]).to_lower()
	return shape_name + "_spawn_limit"


# Get the spawn rate name for a shape
func _get_spawn_rate_name(shape_type: Enums.ShapeType) -> String:
	var shape_name = str(Enums.ShapeType.keys()[shape_type]).to_lower()
	return shape_name + "_spawn_rate"



func _on_spawn_timer_timeout(type: Enums.ShapeType) -> void:
	var limit = StatManager.get_shape_spawn_stat(_get_spawn_limit_name(type))

	if shape_containers[type].get_child_count() >= limit:
		return
	var x_limit: float = get_viewport_rect().size.x / 2.15
	var y_limit: float = get_viewport_rect().size.x / 2.4
	var world_bounds: Array[int] = [-x_limit, x_limit, -y_limit, y_limit]
	var spawn_position: Vector2 = _choose_random_pos(world_bounds)
	spawn_shape(spawn_position, type)
