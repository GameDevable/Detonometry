extends CharacterBody2D


var speed = 250.0
var base_speed = 250.0
var move_direction: Vector2 = Vector2(1, 1)
var bounce_count: int = 0
const FRICTION = 1000
@onready var hitbox: Hitbox = $Hitbox

func _ready() -> void:
	move_direction = Vector2((randf_range(-1, 1)), (randf_range(-1, 1))).normalized()
	print(move_direction)
	_set_radii(StatManager.get_special_modifier_stat("bouncy_ball_size_percent"))
	hitbox.damage = int(StatManager.get_special_modifier_stat("bouncy_ball_damage"))


func _physics_process(delta: float) -> void:
	if speed > base_speed:
		speed = move_toward(speed, base_speed, delta * FRICTION)
	velocity = speed * move_direction
	_check_wall_rays()
	move_and_slide()


func _check_wall_rays() -> void:
	# Checks vertical
	if $WallRays/Up.is_colliding() and move_direction.y < 0:
		move_direction = move_direction.bounce(Vector2.DOWN)
		bounce_count += 1
	elif $WallRays/Down.is_colliding() and move_direction.y > 0:
		move_direction = move_direction.bounce(Vector2.UP)
		bounce_count += 1
	# Checks horizontal
	if $WallRays/Right.is_colliding() and move_direction.x > 0:
		move_direction = move_direction.bounce(Vector2.LEFT)
		bounce_count += 1
	elif $WallRays/Left.is_colliding() and move_direction.x < 0:
		move_direction = move_direction.bounce(Vector2.RIGHT)
		bounce_count += 1
	if StatManager.get_special_modifier_stat("bouncy_ball_bounces") <= bounce_count:
		_despawn()

func _despawn() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "scale", Vector2(0.01, 0.01), 0.6)
	await tween.finished
	queue_free()

func _set_radii(radius: float) -> void:
	var scale_factor = Vector2(1.0, 1.0) * radius
	scale = scale_factor / 100 
	print(scale)
