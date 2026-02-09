@tool
extends Node

func _ready():
	if not Engine.is_editor_hint():
		return
	for container in get_children():
		for child in container.get_children():
			if child is UpgradeNode:
				var icon_node = child.get_node("PurchaseButton/ButtonIcon")
				if icon_node:
					icon_node.texture = child.data.icon
	
