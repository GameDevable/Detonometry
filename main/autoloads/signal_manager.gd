extends Node
# Health System
signal health_changed(diff: int) # The difference can be used for further calculations
signal max_health_changed(diff: int) # The difference can be used for further calculations
signal health_depleted
signal damage_taken(value: int)
 
# bombs
signal bomb_detonated(shapes_broken: Array[Shape])
signal bomb_created
signal bomb_placed
# Shapes
signal shape_broken(instance: Shape, by_bomb: bool)

# Ui
signal points_changed(new_value: int)
signal session_points_changed(new_value: int)
signal place_delay_timer_changed(value: float)
signal delay_timer_out()
signal mouse_dragging(is_dragging: bool)
signal detonation_idx_value_changed(new_value: int)
# Spawn System
signal spawn_shape_request(position: Vector2, shape_type: Enums.ShapeType, modifiers: Array[ShapeModifierComponent])
signal spawn_shape_bunch_request(amount: int, positions: Array[Vector2], shape_types: Array[Enums.ShapeType], modifier_array: Array[Array])
signal spawn_sierpinski_triangles(triangle_position: Vector2, modifier_arrays_array: Array[Array])

# World
signal spawn_bomb(bomb_position: Vector2)
signal unsuccessful_bomb_place
signal session_restarted
signal session_timer_updated(value: float)
signal session_ended(session_data)
signal frenzy_ended 
signal frenzy_started
# Upgrades
signal upgrade_purchased(upgrade: Upgrade)
signal upgrade_advanced(upgrade: Upgrade)
signal upgrade_unlocked(upgrade: Upgrade)
signal upgrade_locked(upgrade: Upgrade)
signal purchase_amount_changed(value: int)
