extends Node2D
signal emptied


func _on_child_exiting_tree(_node: Node) -> void:
	if get_child_count() == 1:
		emptied.emit()
