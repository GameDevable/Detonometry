extends Control
var resolutions: Dictionary[String, Vector2i] = {
	"640x360": Vector2i(640, 360),
	"1280x720": Vector2i(1280, 720),
	"1600x900": Vector2i(1600, 900),
	"1920x960": Vector2i(1920, 960),
	"2560x1440": Vector2i(2560, 1440),
	"3840x2160": Vector2i(3840, 2160)
}
var current_resolution: String = "1280x720"
var current_resolution_idx: int = 1
var is_fullscreened: bool = false
var settings_data: Dictionary = {}
@onready var back_button: Button = $BackButton
@onready var button_scale_effect: UiEffectComponent = $BackButton/ButtonScaleEffect
@onready var master_volume_slider: HSlider = $ContentMargins/ContentLayout/Audio/MasterVolumeSlider
@onready var sfx_volume_slider: HSlider = $ContentMargins/ContentLayout/Audio/SFXVolumeSlider
@onready var music_slider: HSlider = $ContentMargins/ContentLayout/Audio/MusicSlider
@onready var resolution_options: OptionButton = $ContentMargins/ContentLayout/Display/ResolutionOptions
@onready var fullscreen_checkbox: CheckBox = $ContentMargins/ContentLayout/Display/FullscreenCheckbox


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
	_load_saved_data(SaveManager.get_settings_cfg())


func _get_settings_data() -> Dictionary:
	settings_data = {"audio": {"master_volume": master_volume_slider.value, 
	"sfx_volume" : sfx_volume_slider.value, "music_volume" : music_slider.value
	}, "display" : { "resolution" : current_resolution, "resolution_idx" : current_resolution_idx, "fullscreened" : is_fullscreened}}
	return settings_data


func _load_saved_data(data: Dictionary) -> void:
	if data == {}:
		return
	var audio_data = data["audio"]
	master_volume_slider.value = audio_data["master_volume"]
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume_slider.value))

	sfx_volume_slider.value = audio_data["sfx_volume"]
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume_slider.value))

	music_slider.value = audio_data["music_volume"]
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_slider.value))

	var display_data = data["display"]
	var resolution: String = display_data["resolution"]
	resolution = resolution.substr(1, resolution.length() - 2)
	current_resolution = display_data["resolution"]
	current_resolution_idx = display_data["resolution_idx"]
	resolution_options.selected = current_resolution_idx
	DisplayServer.window_set_size(resolutions[current_resolution])
	
	is_fullscreened = display_data["fullscreened"]
	if is_fullscreened:
		fullscreen_checkbox.toggled.emit(true)


func _on_back_button_pressed() -> void:
	EffectManager.play_sfx(Constants.BUTTON_CLICK_SOUND, 0.0, Constants.BUTTON_CLICK_VOLUME, Constants.BUTTON_CLICK_PITCH)
	UiManager.transition_to(UiManager.previous_menu)
	SaveManager.save_settings(_get_settings_data())


func _on_back_button_mouse_entered() -> void:
	var base_pitch: float = 1.0
	EffectManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)
	var end_scale: Vector2 = Vector2(1.1, 1.1)
	button_scale_effect.scale_ui(back_button.scale, end_scale)


func _on_back_button_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON, Input.CURSOR_ARROW)
	var end_scale: Vector2 = Vector2(1.0, 1.0)
	button_scale_effect.scale_ui(back_button.scale, end_scale, Tween.TRANS_EXPO)


func _on_check_box_toggled(toggled_on: bool) -> void:
	is_fullscreened = toggled_on
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
	current_resolution = option_string
	current_resolution_idx = index
	var window = get_window()
	window.size = new_resolution
	_center_window()


func _center_window() -> void:
	var screen = DisplayServer.screen_get_size()
	var window = DisplayServer.window_get_size()
	DisplayServer.window_set_position((screen - window) / 2)
