class_name Shape
extends CharacterBody2D
var base_modulate: Color = modulate
var explosion_detected_modulate: Color = Color(0.5, 0.5, 0.5)
var is_scaled: bool = false
var move_direction: Vector2 = Vector2(1, 1)
var prev_pos: Vector2 = Vector2.ZERO
var speed: float = 10.0
var base_speed: float = 0.0
var modifier_multipliers_total: float = 1.0
var modifier_value_adders_total: float = 0.0
var shape_data: ShapeData = null
var spin_direction: int = 0
var spin_speed: float = 0.0
var inside_area: bool = false
const OFFSCREEN_PADDING: int = 20
const FRICTION: int = 1000
const REINFORCED_PATH_BEGIN: String = "res://upgrade system/assets/upgrade_overlays/reinforced_"

const SHAPE_BREAK = preload("uid://wvbgrwinvj57")
const SHAPE_BREAK1 = preload("uid://bttsomosik4a2")

const BREAK_PARTICLES = preload("uid://bj1jgl6835u7y")

const BREAK_CIRCLE_PARTICLES_TEXTURE_SHEET = preload("uid://hgty7lnbyr77")
const BREAK_SQUARE_PARTICLES_TEXTURE_SHEET = preload("uid://bet2jldxif1tm")
const BREAK_TRIANGLE_PARTICLES_TEXTURE_SHEET = preload("uid://b5wyw4gfsynki")

@onready var shape_sprite: Sprite2D = $ShapeSprite
@onready var modifier_overlay_sprites: Node2D = $ModifierOverlaySprites
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var explosion_detector: Area2D = $ExplosionDetector

@onready var hurtbox_collider: CollisionShape2D = $Hurtbox/HurtboxCollider
@onready var detector_collider: CollisionShape2D = $ExplosionDetector/DetectorCollider
@onready var shape_collider: CollisionShape2D = $ShapeCollider

@onready var health: Health = $Health


func _ready() -> void:
	while spin_direction == 0:
		spin_direction = randi_range(-1, 1)
	rotation = randi_range(-180, 180)
	spin_speed = randf_range(0.8, 1.2)
	$WallRays.global_rotation = 0.0
	prev_pos = position
	# Sets Colliders
	var collision_shape: Shape2D = shape_data.shape_collider
	hurtbox_collider.set_deferred("shape", collision_shape)
	detector_collider.set_deferred("shape", collision_shape)
	shape_collider.set_deferred("shape", collision_shape)
	# Sets Health
	var health_amount = StatManager.get_shape_health(shape_data.shape_type)
	health.set_max_health(health_amount)
	health.set_health(health_amount)
	SignalManager.health_depleted.connect(_on_health_depleted)
	SignalManager.health_changed.connect(_on_health_changed)
	
	shape_sprite.texture = shape_data.shape_texture
	
	var initial_scale = Vector2(0.01, 0.01)
	shape_sprite.scale = initial_scale
	modifier_overlay_sprites.scale = initial_scale
	for child in get_children():
		if child is ShapeModifierComponent:
			child.apply_modifier()
			child.swap_textures()
	var scale_up_tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	var scale_up_time: float = 0.2
	var final_scale: Vector2 = Vector2(1.0, 1.0) * Constants.SPRITE_SCALE
	scale_up_tween.tween_property(shape_sprite, "scale", final_scale, scale_up_time)
	scale_up_tween.parallel().tween_property(modifier_overlay_sprites, "scale", final_scale, scale_up_time)
	# This will make it feel a little nicer
	move_direction = move_direction.normalized()
	shape_sprite.material = shape_sprite.material.duplicate()
	await get_tree().create_timer(scale_up_time / 2).timeout
	hurtbox_collider.disabled = false


func _physics_process(delta: float) -> void:
	if speed > base_speed:
		speed = move_toward(speed, base_speed, delta * FRICTION)
	velocity = speed * move_direction
	var rotation_increase = delta * spin_direction * spin_speed
	shape_collider.rotation += rotation_increase
	hurtbox.rotation += rotation_increase
	explosion_detector.rotation += rotation_increase
	modifier_overlay_sprites.rotation += rotation_increase
	shape_sprite.rotation += rotation_increase
	
	_check_wall_rays()
	move_and_slide()


func get_value() -> float:
	var base_value: int = StatManager.get_shape_value(shape_data.shape_type)
	var total_value: int = (base_value + modifier_value_adders_total) * modifier_multipliers_total
	return total_value


func add_modifier_overlay(texture: Texture2D, overlay_sprite_name: String, z_order: int = 0) -> Sprite2D:
	var overlay_sprite: Sprite2D = Sprite2D.new()
	overlay_sprite.texture = texture
	overlay_sprite.z_index = z_order
	overlay_sprite.z_as_relative = true
	overlay_sprite.name = overlay_sprite_name
	modifier_overlay_sprites.add_child(overlay_sprite)
	overlay_sprite.owner = modifier_overlay_sprites
	return overlay_sprite


func _check_wall_rays() -> void:
	# Checks vertical
	if $WallRays/Up.is_colliding() and move_direction.y < 0:
		move_direction = move_direction.bounce(Vector2.DOWN)
	elif $WallRays/Down.is_colliding() and move_direction.y > 0:
		move_direction = move_direction.bounce(Vector2.UP)
	# Checks horizontal
	if $WallRays/Right.is_colliding() and move_direction.x > 0:
		move_direction = move_direction.bounce(Vector2.LEFT)
	elif $WallRays/Left.is_colliding() and move_direction.x < 0:
		move_direction = move_direction.bounce(Vector2.RIGHT)


func _modulate_based_on_health(_health_ratio: float) -> void:
	var modulate_change: float = 0.9
	explosion_detected_modulate *= modulate_change
	explosion_detected_modulate.a = 1.0
	base_modulate *= modulate_change
	base_modulate.a = 1.0


func _play_global_particles() -> void:
	match shape_data.shape_type:
		Enums.ShapeType.TRIANGLE:
			EffectManager.spawn_particles(BREAK_PARTICLES, global_position, 0.0, BREAK_TRIANGLE_PARTICLES_TEXTURE_SHEET)
		Enums.ShapeType.SQUARE:
			EffectManager.spawn_particles(BREAK_PARTICLES, global_position, 0.0, BREAK_SQUARE_PARTICLES_TEXTURE_SHEET)
		Enums.ShapeType.CIRCLE:
			EffectManager.spawn_particles(BREAK_PARTICLES, global_position, 0.0, BREAK_CIRCLE_PARTICLES_TEXTURE_SHEET)


func _play_local_particles(particle_scale: Vector2) -> void:
	print(particle_scale)
	match shape_data.shape_type:
		Enums.ShapeType.TRIANGLE:
			_spawn_particle(BREAK_PARTICLES, BREAK_TRIANGLE_PARTICLES_TEXTURE_SHEET, particle_scale)
		Enums.ShapeType.SQUARE:
			_spawn_particle(BREAK_PARTICLES, BREAK_SQUARE_PARTICLES_TEXTURE_SHEET, particle_scale)
		Enums.ShapeType.CIRCLE:
			_spawn_particle(BREAK_PARTICLES, BREAK_CIRCLE_PARTICLES_TEXTURE_SHEET, particle_scale)


func _spawn_particle(particle_scene: PackedScene, custom_texture: Texture2D, particle_scale: Vector2) -> void:
	var particle_node: GPUParticles2D = particle_scene.instantiate()
	particle_node.scale = particle_scale
	if custom_texture:
		particle_node.texture = custom_texture
	add_child(particle_node)
	particle_node.emitting = true
	await particle_node.finished
	particle_node.queue_free()


func _on_explosion_detector_area_entered(area: Area2D) -> void:
	if area.name == "ExplosionDetectionArea":
		modulate = explosion_detected_modulate
		inside_area = true


func _on_explosion_detector_area_exited(area: Area2D) -> void:
	if area.name == "ExplosionDetectionArea":
		modulate = base_modulate
		inside_area = false


func _on_health_changed(health_node: Health, _diff: int) -> void:
	if health_node == $Health:
		var health_ratio: float = float(health_node.health) / float(health_node.max_health)
		# Since Reinforced doubles the health we need to modify these checks to account for that
		var reinforced_overlay: Sprite2D = modifier_overlay_sprites.find_child("ReinforcedOverlay")
		if health_ratio <= 0.5:
			if reinforced_overlay:
				reinforced_overlay.visible = false
				
		if health.health != 0 and health.health != health.max_health:
			_play_local_particles(Vector2(0.3, 0.3))
		if reinforced_overlay:
			shape_sprite.material.set_shader_parameter("opaque_ratio", health_ratio * 2)
		else:
			shape_sprite.material.set_shader_parameter("opaque_ratio", health_ratio)


func _on_health_depleted(health_node: Health) -> void:
	if health_node in get_children():
		for child in get_children():
			if child is ShapeModifierComponent:
				child.activate_ability()
				
		_play_global_particles()
		SignalManager.shape_broken.emit(self, inside_area)
