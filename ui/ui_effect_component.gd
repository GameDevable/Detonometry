class_name UiEffectComponent

extends Node
@export var anim_duration: float = 1.0
@export var ease_type: Tween.EaseType = Tween.EASE_OUT
@export var trans_type: Tween.TransitionType = Tween.TRANS_LINEAR

@onready var ui: Control = get_parent()
var tween: Tween = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func reset_tween(easing_type: Tween.EaseType, transition_type: Tween.TransitionType) -> void:
	if tween:
		tween.kill()
	tween = create_tween().set_ease(easing_type).set_trans(transition_type).set_parallel(true)


func scale_ui(beginning_scale: Vector2, final_scale: Vector2, trans_override: Tween.TransitionType = trans_type, ease_override: Tween.EaseType = ease_type) -> void:
	var easing_type: Tween.EaseType = ease_type
	var transition_type: Tween.TransitionType = trans_type
	if trans_override != trans_type:
		transition_type = trans_override
	if ease_override != ease_type:
		ease_type = ease_override
	reset_tween(easing_type, transition_type)
	tween.tween_property(ui, "scale", final_scale, anim_duration).from(beginning_scale)

func scale_ui_min_size( beginning_size: Vector2, final_size: Vector2, trans_override: Tween.TransitionType = trans_type, ease_override: Tween.EaseType = ease_type) -> void:

	var easing_type: Tween.EaseType = ease_type
	var transition_type: Tween.TransitionType = trans_type

	if trans_override != trans_type:
		transition_type = trans_override

	if ease_override != ease_type:
		easing_type = ease_override

	reset_tween(easing_type, transition_type)

	tween.tween_property(ui, "custom_minimum_size", final_size, anim_duration).from(beginning_size)
