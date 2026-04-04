extends ProgressBar
@export var label: Label = null
var threshold_names: Array[String] = ["Amature Popper", "Baby Boomer", "Dastardly Detonator"]
var threshold_time: float = 0.25
var progress_time: float = 0.75

func _ready() -> void:
	label.text = threshold_names[0]

func anim_to_current_threshold() -> void:
	var current_threshold: int = 0
	var thresholds: Array[int] = GameManager.detonation_thresholds
	while current_threshold < GameManager.current_met_threshold:
		var threshold_tween = get_tree().create_tween()
		label.text = threshold_names[current_threshold]
		max_value = thresholds[current_threshold]
		threshold_tween.tween_property(self, "value", thresholds[current_threshold], threshold_time)
		await threshold_tween.finished
		value = 0
		current_threshold += 1
	max_value = thresholds[current_threshold]
	var tween = get_tree().create_tween()
	label.text = threshold_names[current_threshold]
	tween.tween_property(self, "value", GameManager.detonation_idx_value, progress_time)
