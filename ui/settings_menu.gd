extends Control
var resolutions: Dictionary[String, Vector2i] = {
	"640x360": Vector2i(640, 360),
	"1280x720": Vector2i(1280, 720),
	"1600x900": Vector2i(1600, 900),
	"1920x960": Vector2i(1920, 960),
	"2560x1440": Vector2i(2560, 1440),
	"3840x2160": Vector2i(3840, 2160)
}
@onready var back_button: Button = $BackButton
@onready var button_scale_effect: UiEffectComponent = $BackButton/ButtonScaleEffect
@onready var master_volume_slider: HSlider = $ContentMargins/ContentLayout/Audio/MasterVolumeSlider
@onready var sfx_volume_slider: HSlider = $ContentMargins/ContentLayout/Audio/SFXVolumeSlider
@onready var music_slider: HSlider = $ContentMargins/ContentLayout/Audio/MusicSlider
@onready var resolution_options: OptionButton = $ContentMargins/ContentLayout/Display/ResolutionOptions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	master_volume_slider.drag_started.connect(_on_drag_started)
	sfx_volume_slider.drag_started.connect(_on_drag_started)
	music_slider.drag_started.connect(_on_drag_started)
	master_volume_slider.drag_ended.connect(_on_drag_ended)
	sfx_volume_slider.drag_ended.connect(_on_drag_ended)
	music_slider.drag_ended.connect(_on_drag_ended)
	var starting_bus_volume: float = 0.7
	master_volume_slider.value = starting_bus_volume
	sfx_volume_slider.value = starting_bus_volume
	music_slider.value = starting_bus_volume
	_on_master_volume_slider_value_changed(starting_bus_volume)
	_on_sfx_volume_slider_value_changed(starting_bus_volume)
	_on_music_slider_value_changed(starting_bus_volume)



func _on_back_button_pressed() -> void:
	UiManager.transition_to(UiManager.previous_menu)


func _on_back_button_mouse_entered() -> void:
	var base_pitch: float = 1.0
	EffectManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)
	Input.set_custom_mouse_cursor(Constants.POINTER_HAND_CURSOR_ICON, Input.CURSOR_POINTING_HAND)
	var end_scale: Vector2 = Vector2(1.1, 1.1)
	button_scale_effect.scale_ui(back_button.scale, end_scale)


func _on_back_button_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON, Input.CURSOR_ARROW)
	var end_scale: Vector2 = Vector2(1.0, 1.0)
	button_scale_effect.scale_ui(back_button.scale, end_scale, Tween.TRANS_EXPO)


func _on_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_drag_started() -> void:
	Input.set_custom_mouse_cursor(Constants.DRAG_HAND_CURSOR_ICON)


func _on_drag_ended(_value_changed: bool) -> void:
	Input.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON)


func _on_master_volume_slider_value_changed(value: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_idx,linear_to_db(value))


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_idx,linear_to_db(value))


func _on_music_slider_value_changed(value: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))


func _on_option_button_item_selected(index: int) -> void:
	var option_string: String = resolution_options.get_item_text(index)
	var new_resolution: Vector2i = resolutions[option_string] 
	var window = get_window()
	window.size = new_resolution
	_center_window()
	
func _center_window() -> void:
	var screen = DisplayServer.screen_get_size()
	var window = DisplayServer.window_get_size()
	DisplayServer.window_set_position((screen - window) / 2)
