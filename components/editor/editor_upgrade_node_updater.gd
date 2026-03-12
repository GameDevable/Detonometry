@tool
extends Node
@export var grid_size: Vector2 = Vector2(200, 200)
@export var control_node: Control = null

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		for container in control_node.get_children():
			for child in container.get_children():
				if child is UpgradeNode:
					_snap_to_grid(child)
					_update_icon(child)


func _snap_to_grid(node: Control) -> void:
	var offset: Vector2 = Vector2(37.5, 0)
	var new_global_position: Vector2 = (node.global_position - offset).snapped(grid_size) + offset
	
	node.global_position = new_global_position  
	

func _update_icon(node: UpgradeNode) -> void:
	var icon_rect: TextureRect = node.get_child(0).get_child(0)
	if not icon_rect or not node.data:
		return
		
	icon_rect.texture = node.data.icon
