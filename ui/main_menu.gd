extends Control
var first_loadup: bool = true
@onready var buttons_1: VBoxContainer = $Buttons1
@onready var buttons_2: VBoxContainer = $Buttons2

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
