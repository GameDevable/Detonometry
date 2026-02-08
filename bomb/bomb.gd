class_name Bomb
extends Node2D
@export var keep_detection_active: bool = false
@export var detonation_time: float = 1.5
var phase_time: float = 0.0
var is_up_pulse: bool = false
var pulse_time: float = 0.46
const RED_CIRCLE_TEXTURE = preload("res://bomb/assets/red_circle.svg")
const EXPLOSION_SOUND = preload("res://bomb/assets/audio/explosion-01.ogg")
const EXPLOSION_PARTICLES_PATH: String = "res://bomb/assets/particles/explosion_particles.tscn"
const DEBRIS_PARTICLES_PATH: String = "res://bomb/assets/particles/debris_particles.tscn"
const SPARK_PARTICLE_PATH: String = "res://bomb/assets/particles/sparks_particles.tscn"
const BLAST_PARTICLE_PATH: String = "res://bomb/assets/particles/blast_particle.tscn"
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


func _process(delta: float) -> void:
	phase_time += delta
	if phase_time > 1.0:
		phase_time -= 1.0


func handle_placed() -> void:
	# TO DO: Play a placing sound
	
	detonation_timer.start(detonation_time)

	if not keep_detection_active:
		explosion_detection_area.monitorable = false
		explosion_detection_area.monitoring = false
		
	explosion_area_sprite.texture = RED_CIRCLE_TEXTURE
	_start_pulse(Vector2(0.9, 0.9) * Constants.SPRITE_SCALE, 0.47)


func _set_radii(explosion_radius: float) -> void:
	var scale_factor: float = explosion_radius / StatManager.bomb_stats["explosion_radius"] 
	explosion_area_sprite.scale = Vector2(scale_factor, scale_factor)
	hitbox_collider.shape.radius = explosion_radius
	detection_area_collider.shape.radius = explosion_radius


func _handle_explosion_effects() -> void:
	var volume: float = 3.75
	var pitch: float = 0.75
	AudioManager.play_sfx(EXPLOSION_SOUND, 0.0, volume, pitch)
	
	ParticleManager.spawn_particles(BLAST_PARTICLE_PATH, position)
	var delay: float = 0.05
	ParticleManager.spawn_particles(SPARK_PARTICLE_PATH, position, delay)
	ParticleManager.spawn_particles(DEBRIS_PARTICLES_PATH, position + Vector2(0, 20), delay)
	ParticleManager.spawn_particles(EXPLOSION_PARTICLES_PATH, position, delay)


func _handle_detonated_shapes(shapes_inside_range: Array[Node2D]) -> void:
	var shapes_broken: Array[Node2D] = []
	for shape in shapes_inside_range:
		if shape is Shape:
			if shape.health.health <= 0:
				shapes_broken.append(shape)
	SignalManager.bomb_detonated.emit(shapes_broken)


func _start_pulse(scale_value: Vector2, alpha_value: float) -> void:
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
	var tween_time: float = 0.08
	var final_scale: Vector2 = Vector2(1.5, 1.5) * Constants.SPRITE_SCALE
	
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
