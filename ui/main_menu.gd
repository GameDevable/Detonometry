extends Control
var first_loadup: bool = true
@onready var buttons_1: VBoxContainer = $Buttons1
@onready var buttons_2: VBoxContainer = $Buttons2

@onready var confirmation_box: Panel = $ConfirmationBox

@onready var new_game_button_2: Button = $Buttons2/NewGameButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game_button_2.pressed.disconnect(new_game_button_2._on_pressed)
	if not first_loadup:
		buttons_2.visible = true
	else:
		buttons_1.visible = true


func save() -> Dictionary:
	return {"first_loadup" : first_loadup}


func load_save_data(data: Dictionary) -> void:
	first_loadup = data["first_loadup"]


func handle_entered() -> void:
	confirmation_box.visible = false
	if not first_loadup:
		buttons_1.visible = false
		buttons_2.visible = true
	else:
		buttons_1.visible = true
		buttons_2.visible = false


func _on_new_game_button_pressed() -> void:
	confirmation_box.visible = true
