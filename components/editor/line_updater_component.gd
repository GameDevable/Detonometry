@tool
extends Node
@export var connector_container: Control = null

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	for container in connector_container.get_children():
		for child in container.get_children():
			if child is UpgradeConnector:
				var connector: UpgradeConnector = child as UpgradeConnector
				_update_connector(connector)

func _update_connector(connector: UpgradeConnector) -> void:
	if not connector.dependent_node or not connector.root_node:
		return
	var purchase_button_a: Button = connector.dependent_node.get_node("PurchaseButton")
	var purchase_button_b: Button = connector.root_node.get_node("PurchaseButton")
	var center_offset: Vector2 = purchase_button_a.size * 0.25 * connector_container.get_parent().scale
	var point_a: Vector2 = connector.to_local(purchase_button_a.global_position + center_offset)
	var point_b: Vector2 = connector.to_local(purchase_button_b.global_position + center_offset )
	#print(point_a, " ", point_b, " ", connector.root_node.global_position, " ", connector.dependent_node.global_position)
	connector.points = [point_a, point_b]
