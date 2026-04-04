extends Marker2D
var exist_time: float = 0.0
var cluster_scale_val: Vector2 = Vector2(1, 1)
@onready var ui_effect_component: UiEffectComponent = $Label/UiEffectComponent
@onready var label: Label = $Label

func _ready() -> void:
	var base_font_size: int = 36
	var pos_tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	pos_tween.tween_property(self, "position", position + Vector2(0.0, -50.0), exist_time)
	ui_effect_component.scale_font(base_font_size, round(base_font_size * cluster_scale_val.x), Tween.TRANS_EXPO, Tween.EASE_OUT)
	var transparency_tween: Tween = get_tree().create_tween()
	transparency_tween.tween_property(self, "modulate:a", 0.1, exist_time)
