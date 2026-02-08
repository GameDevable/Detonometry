extends Node
# Health System
signal health_changed(diff: int) # The difference can be used for further calculations
signal max_health_changed(diff: int) # The difference can be used for further calculations
signal health_depleted
signal damage_taken(value: int)
 
# bombs
signal bomb_detonated(shapes_broken: Array[Node2D])
signal bomb_created
signal bomb_placed
# Shapes
signal shape_broken(instance: Shape)

# Ui
signal points_changed(new_value: int)
signal place_delay_timer_changed(value: float)
signal mouse_dragging(is_dragging: bool)
# Spawn System
signal spawn_shape_request(position: Vector2, shape_type: Enums.ShapeType, modifiers: Array[Enums.ShapeModifiers])
signal spawn_shape_bunch_request(amount: int, positions: Array[Vector2], shape_types: Array[Enums.ShapeType], modifier_array: Array[Array])
signal spawn_sierpinski_triangles(triangle_position: Vector2, modifier_arrays_array: Array[Array])

# World
signal spawn_bomb(bomb_position: Vector2)
signal unsuccessful_bomb_place
signal play_music
# Upgrades
signal upgrade_purchased(upgrade: Upgrade)
signal upgrade_unlocked(upgrade: Upgrade)
signal purchase_amount_changed(value: int)
