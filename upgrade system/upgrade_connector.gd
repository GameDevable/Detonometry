extends Line2D
@export var node1: UpgradeNode = null
@export var node2: UpgradeNode = null
@export var dependent_node: UpgradeNode = null
@export var unlock_threshold: int = 1
var root_node: UpgradeNode = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	points = [node1.connecting_point, node2.connecting_point]
	if dependent_node == node1:
		root_node = node2
	else:
		root_node = node1
		
	if root_node.is_locked:
		visible = false 
		dependent_node.visible = false
		
	SignalManager.upgrade_purchased.connect(_on_upgrade_purchased)
	SignalManager.upgrade_unlocked.connect(_on_upgrade_unlocked)


func _on_upgrade_purchased(upgrade: Upgrade) -> void:
	if root_node.upgrade == upgrade and upgrade.current_purchased_tier == unlock_threshold:
		dependent_node.unlock()


func _on_upgrade_unlocked(upgrade: Upgrade) -> void:
	if root_node.upgrade == upgrade:
		
		visible = true
		dependent_node.visible = true
