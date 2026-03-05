class_name UpgradeConnector
extends Line2D
@export var root_node: UpgradeNode = null
@export var dependent_node: UpgradeNode = null
@export var unlock_threshold: int = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	points = [root_node.connecting_point, dependent_node.connecting_point]
		
	if root_node.is_locked:
		visible = false 
		dependent_node.visible = false
		
	SignalManager.upgrade_advanced.connect(_on_upgrade_advanced)
	SignalManager.upgrade_unlocked.connect(_on_upgrade_unlocked)


func _on_upgrade_locked(upgrade: Upgrade) -> void:
	if root_node.upgrade == upgrade:
		visible = false
		dependent_node.visible = false

func _on_upgrade_advanced(upgrade: Upgrade) -> void:
	if root_node.upgrade == upgrade and upgrade.current_purchased_tier >= unlock_threshold:
		dependent_node.unlock()
		var intensity: int = 3
		modulate.r = intensity
		modulate.b = intensity
		modulate.g = intensity


func _on_upgrade_unlocked(upgrade: Upgrade) -> void:
	if root_node.upgrade == upgrade:
		visible = true
		dependent_node.visible = true
