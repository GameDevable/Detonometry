extends Camera2D

@export var base_shake_intensity: float = 3.45
@export var shake_time: float = 0.8
@onready var shake_component: ShakeComponent = $ShakeComponent

func _ready() -> void:
	SignalManager.bomb_detonated.connect(_on_bomb_detonated)


func _on_bomb_detonated(_shapes_broken) -> void:
	var additional_intensity_explosion_damage: float = StatManager.get_bomb_stat("damage") * 0.35
	var additional_intensity_explosion_area: float = StatManager.get_bomb_stat("explosion_radius_size_percent") * 0.02
	var shake_intensity: float =  base_shake_intensity + additional_intensity_explosion_area + additional_intensity_explosion_damage
	shake_intensity = min(shake_intensity, Constants.CAMERA_SHAKE_INTENSITY_CAP)
	shake_component.shake(shake_intensity, shake_time)
