@tool
extends Control

func _ready() -> void:
	if not Engine.is_editor_hint():
		return
	for container in get_children():
		for connecting_line in container.get_children():
			connecting_line = connecting_line as UpgradeConnector
			var center_offset: Vector2 = Vector2(196, 196) * 0.25
			var purchase_button_a: Button = connecting_line.dependent_node.get_node("PurchaseButton")
			var purchase_button_b: Button = connecting_line.root_node.get_node("PurchaseButton")
			var point_a: Vector2 = purchase_button_a.global_position + center_offset 
			var point_b: Vector2 = purchase_button_b.global_position + center_offset
			connecting_line.points = [point_a, point_b]
