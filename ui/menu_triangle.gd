extends TextureRect

# Movement speed in pixels per second
@export var speed: Vector2 = Vector2(80, 60)

# Rotation speed in degrees per second
@export var rotation_speed: float = 0.6  # 180° per second

# Current velocity
var velocity: Vector2
var bounds_multiplier: Vector2 = Vector2(1.1, 1.1)
func _ready() -> void:
	velocity = speed
	position = Vector2(100, 100)  # starting position

func _process(delta: float) -> void:
	# Move the triangle
	position += velocity * delta

	# Rotate the triangle
	rotation += rotation_speed * delta

	# Keep rotation between 0-360
	if rotation_degrees > 360:
		rotation_degrees -= 360
	elif rotation_degrees < 0:
		rotation_degrees += 360

	# Get screen bounds
	var screen_size: Vector2 = DisplayServer.window_get_size()
	var tri_size: Vector2 = size

	# Bounce off left/right edges
	if position.x < 0:
		position.x = 0
		velocity.x = abs(velocity.x)
	elif position.x + tri_size.x * bounds_multiplier.x > screen_size.x:
		position.x = screen_size.x - tri_size.x * bounds_multiplier.x
		velocity.x = -abs(velocity.x)

	# Bounce off top/bottom edges
	if position.y < 0:
		position.y = 0
		velocity.y = abs(velocity.y)
	elif position.y + tri_size.y * bounds_multiplier.y > screen_size.y:
		position.y = screen_size.y - tri_size.y * bounds_multiplier.y
		velocity.y = -abs(velocity.y)
