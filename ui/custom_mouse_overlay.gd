extends Control
var is_handling_unsuccessful_place: bool = false
var progress_bar_cancel: bool = false

const RING_FILL_RED: Texture2D = preload("res://ui/assets/radial_progress_bar_textures/ring_fill_red.svg")
const RING_FILL_WHITE: Texture2D = preload("res://ui/assets/radial_progress_bar_textures/ring_fill_white.svg")
const RING_FILL_YELLOW: Texture2D = preload("res://ui/assets/radial_progress_bar_textures/ring_fill_yellow.svg")
const CANT_PLACE = preload("res://bomb/assets/audio/cant_place.ogg")

@onready var place_delay_progress_bar: TextureProgressBar = $MouseFollowerWrapper/PlaceDelayProgressBar
@onready var mouse_icon: TextureRect = $MouseFollowerWrapper/MouseIcon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.place_delay_timer_changed.connect(_on_place_delay_timer_changed)
	SignalManager.unsuccessful_bomb_place.connect(_on_unsuccessful_bomb_place)
	SignalManager.bomb_created.connect(func() -> void:
		place_delay_progress_bar.visible = false
		UiManager.set_custom_mouse_cursor(Constants.DRAG_HAND_CURSOR_ICON)
	)
	place_delay_progress_bar.pivot_offset = place_delay_progress_bar.size * 0.5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$MouseFollowerWrapper.position = get_global_mouse_position() 


func set_cursor_visible(is_on: bool) -> void:
	mouse_icon.visible = is_on


func set_progress_visible(is_on: bool) -> void:
	place_delay_progress_bar.visible = is_on


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
			mouse_icon.visible = false
		if not place_delay_progress_bar.texture_progress == RING_FILL_YELLOW and not is_handling_unsuccessful_place and not progress_bar_cancel:
			place_delay_progress_bar.texture_progress = RING_FILL_YELLOW
		place_delay_progress_bar.value = place_delay_progress_bar.max_value * (1 - value / StatManager.get_bomb_stat("place_delay"))
	else:
		
		place_delay_progress_bar.value = 100
		await get_tree().create_timer(0.1).timeout
		place_delay_progress_bar.visible = false
		mouse_icon.visible = true
	
