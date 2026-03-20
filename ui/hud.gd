extends Control
@export var base_shake_intensity: float = 2.0
@export var world: World = null

const BOMB_PLACE_SOUND1 = preload("res://bomb/assets/audio/bomb_place_sound1.ogg")
var cached_session_value: int = 0
@onready var session_time_label: Label = $SessionTimeLabel
@onready var session_value_label: Label = $SessionValueLabel



func _ready() -> void:
	SignalManager.bomb_detonated.connect(_on_bomb_detonated)
	
	SignalManager.bomb_placed.connect(func() -> void:
		UiManager.set_custom_mouse_cursor(Constants.OPEN_HAND_CURSOR_ICON)
	)

	SignalManager.session_timer_updated.connect(func(value: float) -> void:
		session_time_label.text = str(snapped(value, 0.1))
		)
	SignalManager.session_points_changed.connect(func(new_value: float) -> void:
		_tween_label_int(session_value_label, cached_session_value, int(new_value), true, 0.3)
		cached_session_value = int(new_value)
		
		)
	SignalManager.session_ended.connect(func(_data) -> void:
		session_value_label.text  = "$" + str(0)
		
	)


func _on_bomb_detonated(_shapes_broken: Array[Node2D]) -> void:
	var shake_intensity: float = base_shake_intensity + StatManager.get_bomb_stat("damage") * 0.25
	shake_intensity = min(shake_intensity, Constants.UI_SHAKE_INTENSITY_CAP)
	$ShakeComponent.shake(shake_intensity, 0.8)


func _tween_label_int(label: Label, starting_value: int, ending_value: int, is_money: bool, time: float) -> void:
	var tween := create_tween()
	tween.tween_method(
		func(value):
			var display_value: int = int(value)
			if is_money:
				label.text = "$" + str(display_value)
			else:
				label.text = " " + str(display_value),
		starting_value,
		ending_value,
		time
	)
