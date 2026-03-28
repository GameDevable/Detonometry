extends Control
@export var base_shake_intensity: float = 2.0
@export var world: World = null

var current_threshold_idx: int = 0

const BOMB_PLACE_SOUND1 = preload("res://bomb/assets/audio/bomb_place_sound1.ogg")
const thresholds: Array[int] = [20, 50, 125, 210, 350]
@onready var session_time_label: Label = $SessionTimeLabel
@onready var session_value_label: Label = $SessionValueLabel
@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	progress_bar.max_value = thresholds[0]
	SignalManager.bomb_detonated.connect(_on_bomb_detonated)
	
	SignalManager.bomb_placed.connect(func() -> void:
		UiManager.set_custom_mouse_cursor(Constants.OPEN_HAND_CURSOR_ICON)
	)
	SignalManager.detonation_idx_value_changed.connect(func(new_value: int) -> void:
		
		if new_value >= thresholds[current_threshold_idx]:
			current_threshold_idx += 1
			
			progress_bar.max_value = thresholds[current_threshold_idx]
			var difference: int = new_value - thresholds[current_threshold_idx - 1]
			progress_bar.value = difference
			GameManager.detonation_idx_value = difference
			return
			
		progress_bar.value = new_value
		)
	SignalManager.session_timer_updated.connect(func(value: float) -> void:
		session_time_label.text = str(snapped(value, 0.1))
		)
	SignalManager.session_points_changed.connect(func(new_value: float) -> void:
		session_value_label.text = "$" + str(int(new_value))
		
		)
	SignalManager.session_ended.connect(func(_data) -> void:
		session_value_label.text  = "$" + str(0)
		
	)


func activate_frenzy() -> void:
	pass



func _on_bomb_detonated(_shapes_broken: Array[Node2D]) -> void:
	var shake_intensity: float = base_shake_intensity + StatManager.get_bomb_stat("damage") * 0.25
	shake_intensity = min(shake_intensity, Constants.UI_SHAKE_INTENSITY_CAP)
	$ShakeComponent.shake(shake_intensity, 0.8)
