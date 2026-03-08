extends Control
@export var base_shake_intensity: float = 2.0
@export var world: World = null

const BOMB_PLACE_SOUND1 = preload("res://bomb/assets/audio/bomb_place_sound1.ogg")

@onready var session_time_label: Label = $SessionTimeLabel

func _ready() -> void:
	SignalManager.bomb_detonated.connect(_on_bomb_detonated)
	
	SignalManager.bomb_placed.connect(func() -> void:
		UiManager.set_custom_mouse_cursor(Constants.OPEN_HAND_CURSOR_ICON)
	)

	SignalManager.session_timer_updated.connect(func(value: float) -> void:
		session_time_label.text = str(snapped(value, 0.1))
		)


func _on_bomb_detonated(_shapes_broken: Array[Node2D]) -> void:
	var shake_intensity: float = base_shake_intensity + StatManager.get_bomb_stat("damage") * Constants.SCALE_RATIO
	shake_intensity = min(shake_intensity, Constants.UI_SHAKE_INTENSITY_CAP)
	$ShakeComponent.shake(shake_intensity, 0.8)
