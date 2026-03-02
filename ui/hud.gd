extends Control
@export var base_shake_intensity: float = 2.0
@export var world: World = null
var is_handling_unsuccessful_place: bool = false
var mouse_was_hidden = false
var progress_bar_cancel: bool = false
var dragging_bomb: bool = false
const RING_FILL_RED: Texture2D = preload("res://ui/assets/radial_progress_bar_textures/ring_fill_red.svg")
const RING_FILL_WHITE: Texture2D = preload("res://ui/assets/radial_progress_bar_textures/ring_fill_white.svg")
const RING_FILL_YELLOW: Texture2D = preload("res://ui/assets/radial_progress_bar_textures/ring_fill_yellow.svg")
const BOMB_PLACE_SOUND1 = preload("res://bomb/assets/audio/bomb_place_sound1.ogg")
const CANT_PLACE = preload("res://bomb/assets/audio/cant_place.ogg")

@onready var session_time_label: Label = $SessionTimeLabel
@onready var place_delay_progress_bar: TextureProgressBar = $MouseFollowerWrapper/PlaceDelayProgressBar

func _ready() -> void:
	SignalManager.bomb_detonated.connect(_on_bomb_detonated)
	
	SignalManager.bomb_placed.connect(func() -> void:
		dragging_bomb = false
		Input.set_custom_mouse_cursor(Constants.OPEN_HAND_CURSOR_ICON, Input.CURSOR_ARROW, Constants.DRAG_HAND_CURSOR_ICON.get_size() / 2)
	)
	SignalManager.place_delay_timer_changed.connect(_on_place_delay_timer_changed)
	SignalManager.unsuccessful_bomb_place.connect(_on_unsuccessful_bomb_place)
	SignalManager.session_timer_updated.connect(func(value: float) -> void:
		session_time_label.text = str(snapped(value, 0.1))
		)
	SignalManager.bomb_created.connect(func() -> void:
		place_delay_progress_bar.visible = false
		dragging_bomb = true
		Input.set_custom_mouse_cursor(Constants.DRAG_HAND_CURSOR_ICON, Input.CURSOR_ARROW, Constants.DRAG_HAND_CURSOR_ICON.get_size() / 2)
		)

	place_delay_progress_bar.pivot_offset = place_delay_progress_bar.size * 0.5


func _process(_delta: float) -> void:
	$MouseFollowerWrapper.position = get_global_mouse_position() 


func handle_shown() -> void:
	place_delay_progress_bar.visible = false


func _on_bomb_detonated(_shapes_broken: Array[Node2D]) -> void:
	var shake_intensity: float = base_shake_intensity + StatManager.get_bomb_stat("damage") * Constants.SCALE_RATIO
	shake_intensity = min(shake_intensity, Constants.UI_SHAKE_INTENSITY_CAP)
	$ShakeComponent.shake(shake_intensity, 0.8)


func _on_unsuccessful_bomb_place() -> void:
	if is_handling_unsuccessful_place:
		return
	is_handling_unsuccessful_place = true
	var base_size: Vector2 = Vector2(0.818, 0.818)
	
	var final_size:Vector2 = Vector2(1.0, 1.0)
	
	var tween_time: float = 0.06
	var hold_time: float = 0.22
	
	var ring_scale_up_tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	
	ring_scale_up_tween.tween_property(place_delay_progress_bar, "scale", final_size, tween_time)
	
	place_delay_progress_bar.texture_progress = RING_FILL_RED
	EffectManager.play_sfx(CANT_PLACE, 0.0, 2.0, 0.8)
	await ring_scale_up_tween.finished
	await get_tree().create_timer(hold_time).timeout
	place_delay_progress_bar.texture_progress = RING_FILL_YELLOW
	var ring_scale_down_tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	ring_scale_down_tween.tween_property(place_delay_progress_bar, "scale", base_size, tween_time)
	await ring_scale_down_tween.finished
	is_handling_unsuccessful_place = false


func _on_place_delay_timer_changed(value: float) -> void:
	if not visible:
		return
	if value > 0.0:
		if not place_delay_progress_bar.visible and not progress_bar_cancel:
			place_delay_progress_bar.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		if not place_delay_progress_bar.texture_progress == RING_FILL_YELLOW and not is_handling_unsuccessful_place and not progress_bar_cancel:
			place_delay_progress_bar.texture_progress = RING_FILL_YELLOW
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		place_delay_progress_bar.value = place_delay_progress_bar.max_value * (1 - value / StatManager.get_bomb_stat("place_delay"))
	else:
		place_delay_progress_bar.value = 100
		place_delay_progress_bar.visible = false
		if not Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
