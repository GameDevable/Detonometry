extends Control
var is_transitioning: bool = false
var transition_speed: int = 500
var tween: Tween = null
@onready var color_rect: ColorRect = $ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.position.x = -get_viewport_rect().size.x


func transition_position(final_val: Vector2) -> void:
	if tween:
		tween.kill()
	set_up_tween()
	tween.tween_property(color_rect, "position", final_val, 0.6)
	await tween.finished


func set_up_tween() -> void:
	tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)


func reset() -> void:
	visible = false
	color_rect.position.x = -get_viewport_rect().size.x
