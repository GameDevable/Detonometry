extends Node2D
signal emptied

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_child_exiting_tree(node: Node) -> void:
	if get_child_count() == 1:
		emptied.emit()
		print("SDF")
