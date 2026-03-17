class_name Bomb
extends Node2D
@export var keep_detection_active: bool = false
var pulse_time: float = 0.35
var is_up_pulse: bool = false
var is_pulsing: bool = true
const RED_CIRCLE_TEXTURE = preload("res://bomb/assets/red_circle.svg")
const EXPLOSION_SOUND = preload("res://bomb/assets/audio/explosion-01.ogg")

const DEBRIS_PARTICLES = preload("uid://cwvgah0m7wfey")
const BLAST_PARTICLE = preload("uid://db1td87mfq0rt")
const EXPLOSION_PARTICLES = preload("uid://cc8hnlp15466b")
const SPARK_PARTICLES = preload("uid://jjxpg78gpkdj")



@onready var bomb_sprite: Sprite2D = $BombSprite
@onready var explosion_area_sprite: Sprite2D = $ExplosionAreaSprite
@onready var explosion_area_hitbox: Hitbox = $ExplosionAreaHitbox

@onready var hitbox_collider: CollisionShape2D = $ExplosionAreaHitbox/HitboxCollider
@onready var detection_area_collider: CollisionShape2D = $ExplosionDetectionArea/DetectionAreaCollider
@onready var explosion_detection_area: Area2D = $ExplosionDetectionArea
@onready var push_area_collider: CollisionShape2D = $ExplosionPushArea/PushAreaCollider
@onready var detonation_timer: Timer = $DetonationTimer

func _ready() -> void:
	var radius: float = StatManager.get_bomb_stat("explosion_radius")
	bomb_sprite.scale = Vector2(Constants.SPRITE_SCALE, Constants.SPRITE_SCALE)
	_set_radii(radius)


func handle_placed() -> void:
	detonation_timer.start(StatManager.bomb_stats["explosion_time"])

	if not keep_detection_active:
		explosion_detection_area.monitorable = false
		explosion_detection_area.monitoring = false
		
	explosion_area_sprite.texture = RED_CIRCLE_TEXTURE
	$RadiusLight.color = Color(1.0, 0.195, 0.145, 1.0)
	var transparency_value: float = 0.47
	_start_pulse(Vector2(0.9, 0.9) * Constants.SPRITE_SCALE, transparency_value)


func _set_radii(explosion_radius: float) -> void:
	var scale_factor: float = explosion_radius / StatManager.bomb_stats["explosion_radius"] 
	explosion_area_sprite.scale = Vector2(scale_factor, scale_factor)
	hitbox_collider.shape.radius = explosion_radius
	detection_area_collider.shape.radius = explosion_radius
	$RadiusLight.texture_scale = scale_factor


func _handle_explosion_effects() -> void:
	var volume: float = -2.0
	var pitch: float = 1.0
	EffectManager.play_sfx(EXPLOSION_SOUND, 0.0, volume, pitch)
	var scale_factor: float = StatManager.get_bomb_stat("explosion_radius_size_percent") / 100.0
	EffectManager.spawn_particles(BLAST_PARTICLE, position, 0.0, null, Vector2(scale_factor, scale_factor))
	
	var delay: float = 0.03 
	EffectManager.spawn_particles(SPARK_PARTICLES, position, delay, null, Vector2(scale_factor, scale_factor))
	EffectManager.spawn_particles(DEBRIS_PARTICLES, position + Vector2(0, 20), delay, null, Vector2(scale_factor, scale_factor))
	EffectManager.spawn_particles(EXPLOSION_PARTICLES, position, delay, null, Vector2(scale_factor, scale_factor))


func _handle_detonated_shapes(shapes_inside_range: Array[Node2D]) -> void:
	var shapes_broken: Array[Node2D] = []
	for shape in shapes_inside_range:
		if not is_instance_valid(shape):
			continue
		if shape is Shape:
			if shape.health.health <= 0:
				shapes_broken.append(shape)
	SignalManager.bomb_detonated.emit(shapes_broken)


func _start_pulse(scale_value: Vector2, alpha_value: float) -> void:
	if not is_pulsing:
		return
	pulse_time = StatManager.bomb_stats["explosion_time"] * 0.36
	var pulse_tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO)
	pulse_tween.parallel().tween_property(
		explosion_area_sprite,
		"self_modulate:a",
		alpha_value,
		pulse_time
	)

	pulse_tween.parallel().tween_property(
		bomb_sprite,
		"scale",
		scale_value,
		pulse_time 
	)
	pulse_tween.finished.connect(_on_pulse_tween_finished)


func _turn_off_colliders() -> void:
	$ExplosionAreaHitbox/HitboxCollider.disabled = true
	$ExplosionDetectionArea/DetectionAreaCollider.disabled = true
	$ExplosionPushArea/PushAreaCollider.disabled = true

func _on_pulse_tween_finished() -> void:
	if not is_pulsing:
		return
	var pulse_scale: Vector2 = Vector2.ZERO
	var pulse_alpha: float = 0.0
	var min_alpha: float = 0.45
	var max_alpha: float = 0.68 
	if is_up_pulse:
		is_up_pulse = false
		pulse_scale = Vector2(0.95, 0.95) * Constants.SPRITE_SCALE
		
		pulse_alpha = min_alpha
	else:
		is_up_pulse = true
		pulse_scale = Vector2(1.05, 1.05) * Constants.SPRITE_SCALE
		pulse_alpha = max_alpha
	_start_pulse(pulse_scale, pulse_alpha)


func _on_explosion_push_area_body_entered(body: Node2D) -> void:
	if body is Shape:
		if not body in explosion_area_hitbox.get_overlapping_bodies() or body.health.health > 0:
			body = body as Shape
			body.move_direction = position.direction_to(body.position)
			var push_force: float = 8.75
			body.speed = body.base_speed * push_force


func _on_detonation_timer_timeout() -> void:
	# TO DO: Handle all explosion effects, particles, sounds, etc...
	hitbox_collider.disabled = false
	push_area_collider.disabled = false
	is_pulsing = false
	var tween_time: float = 0.08
	var final_scale: Vector2 = Vector2(1.6, 1.6) * Constants.SPRITE_SCALE
	
	var scale_up_explosion_tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	scale_up_explosion_tween.tween_property(bomb_sprite, "scale", final_scale, tween_time)
	
	var alpha_explosion_tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	alpha_explosion_tween.tween_property(explosion_area_sprite, "self_modulate:a", 0.68, tween_time)
	
	var shapes_inside_range: Array[Node2D] = explosion_detection_area.get_overlapping_bodies()
	explosion_area_hitbox.damage = StatManager.get_bomb_stat("damage") as int
	await scale_up_explosion_tween.finished
	_handle_explosion_effects()
	queue_free()
	_handle_detonated_shapes(shapes_inside_range)
