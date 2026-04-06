class_name UpgradeConnector
extends Line2D
@export var root_node: UpgradeNode = null 
@export var dependent_node: UpgradeNode = null 
@export var unlock_threshold: int = 1
var threshold: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#points = [root_node.connecting_point, dependent_node.connecting_point]
		
	if root_node.is_locked:
		visible = false 
		dependent_node.visible = false

	threshold = unlock_threshold
	material = material.duplicate()
	var intensity: float = 1.0
	modulate.r = intensity
	modulate.b = intensity
	modulate.g = intensity
	SignalManager.upgrade_advanced.connect(_on_upgrade_advanced)
	SignalManager.upgrade_unlocked.connect(_on_upgrade_unlocked)



func _on_upgrade_locked(upgrade: Upgrade) -> void:
	if root_node.upgrade == upgrade:
		visible = false
		dependent_node.visible = false


func _on_upgrade_advanced(upgrade: Upgrade) -> void:
	if root_node.upgrade == upgrade:
		var ratio = float(upgrade.current_purchased_tier) / float(unlock_threshold)  
		if ratio > 1:
			ratio = 1
		material.set_shader_parameter("opaque_ratio", ratio)
	if root_node.upgrade == upgrade and upgrade.current_purchased_tier >= unlock_threshold:
		dependent_node.unlock()
		material.set_shader_parameter("opaque_ratio", 1.0)


func _on_upgrade_unlocked(upgrade: Upgrade) -> void:
	if root_node.upgrade == upgrade:
		visible = true
		dependent_node.visible = true
		var ratio = float(upgrade.current_purchased_tier) / float(unlock_threshold)  
		if ratio > 1:
			ratio = 1
		material.set_shader_parameter("opaque_ratio", ratio)
