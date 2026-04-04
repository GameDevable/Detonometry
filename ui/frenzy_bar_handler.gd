extends Control
var current_threshold_idx: int = 0

@onready var detonation_idx_bar: ProgressBar = $DetonationIdxBar
@onready var frenzy_bar: ProgressBar = $FrenzyBar
@onready var bar_animator: UiEffectComponent = $FrenzyBar/BarAnimator
const FRENZY_START_SOUND = preload("uid://36q1qoi4ed7q")

@onready var frenzy_timer: Timer = $FrenzyTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	detonation_idx_bar.max_value = GameManager.detonation_thresholds[0]
	SignalManager.detonation_idx_value_changed.connect(func(new_value: int) -> void:
		if new_value >= GameManager.detonation_thresholds[current_threshold_idx]:
			current_threshold_idx += 1
			GameManager.current_met_threshold = current_threshold_idx
			detonation_idx_bar.max_value = GameManager.detonation_thresholds[current_threshold_idx]
			var difference: int = new_value - GameManager.detonation_thresholds[current_threshold_idx - 1]
			detonation_idx_bar.value = difference
			GameManager.detonation_idx_value = difference
			activate_frenzy()
			return
		
		var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		tween.tween_property(detonation_idx_bar, "value", new_value, 0.5)
		)


func _process(_delta: float) -> void:
	if GameManager.in_frenzy:
		frenzy_bar.value = frenzy_timer.time_left


func reset() -> void:
	detonation_idx_bar.value = 0
	frenzy_bar.value = 0


func activate_frenzy() -> void:
	GameManager.in_frenzy = true
	var frenzy_time: float = StatManager.get_session_stat("frenzy_time")
	frenzy_bar.max_value = frenzy_time
	frenzy_bar.value = frenzy_bar.max_value
	frenzy_bar.visible = true
	detonation_idx_bar.visible = false
	frenzy_timer.start(frenzy_time)
	bar_animator.scale_ui(frenzy_bar.scale, Vector2(1.1, 1.1))
	EffectManager.play_sfx(FRENZY_START_SOUND, 0.0, -10, 0.75)


func _on_frenzy_timer_timeout() -> void:
	GameManager.in_frenzy = false
	frenzy_bar.visible = false
	detonation_idx_bar.visible = true
	bar_animator.scale_ui(frenzy_bar.scale, Vector2(1.0, 1.0), Tween.TRANS_LINEAR)
	SignalManager.detonation_idx_value_changed.emit(GameManager.detonation_idx_value)
	
	SignalManager.frenzy_ended.emit()
