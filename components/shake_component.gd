class_name ShakeComponent
extends Node

@export var shake_time_speed: float = 30.0
@export var shake_decay: float = 5.0


var shake_intensity: float = 0.0
var active_shake_time: float = 0.0

var shake_time: float = 0.0

# Used to create sudden movement in different direction
var noise = FastNoiseLite.new()

func _physics_process(delta: float) -> void:
	var offset: Vector2 = Vector2.ZERO
	if active_shake_time > 0:
		shake_time += delta * shake_time_speed
		active_shake_time -= delta
		offset = Vector2(
			noise.get_noise_2d(shake_time, 0) * shake_intensity,
			noise.get_noise_2d(0, shake_time) * shake_intensity
		)
		shake_intensity = max(shake_intensity - shake_decay * delta, 0)
	else:
		var lerp_weight: float = 10.5
		offset = lerp(offset, Vector2.ZERO, lerp_weight * delta)
	get_parent().position = Vector2.ZERO + offset
	#get_parent().position += offset

func shake(intensity: float, time: float) -> void:
	# Makes sure that it is different every time
	randomize()
	noise.seed = randi()
	noise.frequency = 2.0
	
	shake_intensity = intensity
	active_shake_time = time
	shake_time = 0.0
