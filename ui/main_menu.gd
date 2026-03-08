extends Control
var first_loadup: bool = true
@onready var buttons_1: VBoxContainer = $Buttons1
@onready var buttons_2: VBoxContainer = $Buttons2
@onready var playtest_button: Button = $PlaytestButton
@onready var playtest_button_animator: UiEffectComponent = $PlaytestButton/PlaytestButtonAnimator
@onready var discord_button: Button = $DiscordButton
@onready var discord_button_animator: UiEffectComponent = $DiscordButton/DiscordButtonAnimator
@onready var mailing_list_button: Button = $MailingListButton
@onready var mailing_list_button_animator: UiEffectComponent = $MailingListButton/MailingListButtonAnimator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not first_loadup:
		buttons_2.visible = true
	else:
		buttons_1.visible = true


func save() -> Dictionary:
	return {"first_loadup" : first_loadup}


func load_save_data(data: Dictionary) -> void:
	first_loadup = data["first_loadup"]


func handle_entered() -> void:
	if not first_loadup:
		buttons_1.visible = false
		buttons_2.visible = true
	else:
		buttons_1.visible = true
		buttons_2.visible = false


func _on_playtest_button_pressed() -> void:
	EffectManager.play_sfx(Constants.BUTTON_CLICK_SOUND, 0.0, Constants.BUTTON_CLICK_VOLUME, Constants.BUTTON_CLICK_PITCH)
	OS.shell_open("https://docs.google.com/forms/d/1HANikLtPWjl8UpeAejbwBBAJAaE0f1C7P3WvZoPq9Y0/viewform?edit_requested=true")


func _on_playtest_button_mouse_entered() -> void:
	var base_pitch: float = 1.0
	EffectManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)
	playtest_button_animator.scale_ui(playtest_button.scale, Vector2(1.1, 1.1))


func _on_playtest_button_mouse_exited() -> void:
	playtest_button_animator.scale_ui(playtest_button.scale, Vector2(1.0, 1.0), Tween.TRANS_EXPO)


func _on_discord_button_pressed() -> void:
	EffectManager.play_sfx(Constants.BUTTON_CLICK_SOUND, 0.0, Constants.BUTTON_CLICK_VOLUME, Constants.BUTTON_CLICK_PITCH)
	OS.shell_open("https://discord.gg/pnWWQkg7")


func _on_discord_button_mouse_entered() -> void:
	var base_pitch: float = 1.0
	EffectManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)
	discord_button_animator.scale_ui(discord_button.scale, Vector2(1.1, 1.1))


func _on_discord_button_mouse_exited() -> void:
	discord_button_animator.scale_ui(discord_button.scale, Vector2(1.0, 1.0), Tween.TRANS_EXPO)


func _on_mailing_list_button_pressed() -> void:
	EffectManager.play_sfx(Constants.BUTTON_CLICK_SOUND, 0.0, Constants.BUTTON_CLICK_VOLUME, Constants.BUTTON_CLICK_PITCH)
	OS.shell_open("https://game-devable.kit.com/b7d75e609a")


func _on_mailing_list_button_mouse_entered() -> void:
	var base_pitch: float = 1.0
	EffectManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)
	mailing_list_button_animator.scale_ui(mailing_list_button.scale, Vector2(1.1, 1.1))
	

func _on_mailing_list_button_mouse_exited() -> void:
	mailing_list_button_animator.scale_ui(mailing_list_button.scale, Vector2(1.0, 1.0))
