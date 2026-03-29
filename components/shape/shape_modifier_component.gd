class_name ShapeModifierComponent
extends Node
@export var shape_texture: Texture2D = null
@export var overlay_texture: Texture2D = null
# If the modifier needs a shape specific texture, we use this instead
@export var overlay_path: String = ""
@export var overlay_name: String = ""
@export var modifier_weight_name: String = ""
@export var particles: PackedScene = null
@export var sound: AudioStream = null
@export var is_specific_to_one_shape: bool = false
@export var specific_shape: Enums.ShapeType
@export var z_index: int = 0
var shape: Shape = null

func _ready() -> void:
	shape = get_parent()
	if particles:
		await get_tree().create_timer(0.01).timeout
		shape.add_child(particles.instantiate())

# To be overridden
func apply_modifier() -> void:
	pass


func activate_ability() -> void:
	pass


func swap_textures() -> void:
	if shape_texture:
		shape.shape_sprite.texture = shape_texture
	
	if overlay_texture:
		shape.add_modifier_overlay(overlay_texture, overlay_name)
	elif not overlay_path == "":
		var texture_path: String = overlay_path + Enums.ShapeType.keys()[shape.shape_data.shape_type].to_lower() + "_overlay.svg"
		shape.add_modifier_overlay(load(texture_path), overlay_name, z_index)
		
