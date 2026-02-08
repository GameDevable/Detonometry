extends Control
var is_dragging: bool = false
var can_drag: bool = true
var base_button_minimum_size: Vector2 = Vector2.ZERO
const DRAG_SPEED: float = 1.1
const BUTTON_SCALE_TIME: float = 0.4
# Left, right, Bottom, Top
const DRAG_BOUNDS: Array[float] = [-200, 700, -175, 100]
@onready var points_label: Label = $BackgroundPanel/PointsLabel
@onready var upgrade_nodes: Control = $DraggableNodes/UpgradeNodes
@onready var draggable_nodes: Control = $DraggableNodes
@onready var back_to_game_button: Button = $BackgroundPanel/BackToGameButton
@onready var button_animator: Node = $BackgroundPanel/BackToGameButton/ButtonAnimator

func _ready() -> void:
	SignalManager.points_changed.connect(_on_points_changed)
	back_to_game_button.mouse_entered.connect(_on_mouse_entered)
	back_to_game_button.mouse_exited.connect(_on_mouse_exited)
	# Recursively loops through a
	_set_up_buttons(upgrade_nodes)
	base_button_minimum_size = back_to_game_button.custom_minimum_size


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Input.is_action_pressed("bomb_place_action") and can_drag:
			
			is_dragging = true
			SignalManager.mouse_dragging.emit(is_dragging)
			back_to_game_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
			Input.set_custom_mouse_cursor(Constants.DRAG_HAND_CURSOR_ICON, Input.CURSOR_ARROW)#, Constants.DRAG_HAND_CURSOR_ICON.get_size() / 2)
		if Input.is_action_just_released("bomb_place_action") and is_dragging:
			is_dragging = false
			SignalManager.mouse_dragging.emit(is_dragging)
			back_to_game_button.mouse_filter = Control.MOUSE_FILTER_STOP
			
			Input.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON, Input.CURSOR_ARROW)

	if event is InputEventMouseMotion:
		if is_dragging:
			event = event as InputEventMouseMotion
			draggable_nodes.position += event.relative * DRAG_SPEED
			draggable_nodes.position.x = clamp(draggable_nodes.position.x, DRAG_BOUNDS[0], DRAG_BOUNDS[1])
			draggable_nodes.position.y = clamp(draggable_nodes.position.y, DRAG_BOUNDS[2], DRAG_BOUNDS[3])


func handle_entered() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON, Input.CURSOR_ARROW)
	draggable_nodes.position = Vector2.ZERO


func _set_up_buttons(parent_node: Control) -> void:
	for child in parent_node.get_children():
		if child is not UpgradeNode:
			_set_up_buttons(child)
			continue
		var upgrade_node: UpgradeNode = child as UpgradeNode
		upgrade_node.purchase_button.mouse_entered.connect(func() -> void:
			can_drag = false
			upgrade_node._on_purchase_button_mouse_entered()
			)
		upgrade_node.purchase_button.mouse_exited.connect(func() -> void:
			can_drag = true
			upgrade_node._on_purchase_button_mouse_exited()
			)


func _on_points_changed(value: int) -> void:
	points_label.text = "$ " + str(value)
	# Recursively finds the upgrade nodes and adds the number of upgrades that can be purchased to a variable
	var purchasable_node_count: int = _update_buttons(upgrade_nodes, value)
	SignalManager.purchase_amount_changed.emit(purchasable_node_count)


func _update_buttons(parent_node: Control, points_value: int) -> int:
	var purchasable_node_count: int = 0
	for child in parent_node.get_children():
		if child is not UpgradeNode:
			purchasable_node_count += _update_buttons(child, points_value)
			continue
		var upgrade_node: UpgradeNode = child
		# Ignores any values changing if the upgrade is already at max tier
		if upgrade_node.is_at_max_tier():
			continue
		# Checks if the player can now purchase the current buyable tier
		if upgrade_node.can_purchase_tier(points_value):
			purchasable_node_count += 1
			upgrade_node.can_purchase = true
		else:
			upgrade_node.can_purchase = false
		upgrade_node.update_theme()
	return purchasable_node_count


func _on_back_to_game_button_pressed() -> void:
	AudioManager.play_sfx(Constants.BUTTON_CLICK_SOUND, 0.0, Constants.BUTTON_CLICK_VOLUME, Constants.BUTTON_CLICK_PITCH)
	UiManager.swap_menu("None")
	UiManager.show_overlay("Hud")
	Input.set_custom_mouse_cursor(Constants.OPEN_HAND_CURSOR_ICON, Input.CURSOR_ARROW, Constants.OPEN_HAND_CURSOR_ICON.get_size() / 2)


func _on_mouse_entered() -> void:
	can_drag = false
	var base_pitch: float = 1.0
	AudioManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)
	Input.set_custom_mouse_cursor(Constants.POINTER_HAND_CURSOR_ICON, Input.CURSOR_POINTING_HAND)
	var end_scale: Vector2 = Vector2(1.1, 1.1)
	button_animator.scale_parent(end_scale, base_button_minimum_size, BUTTON_SCALE_TIME, Tween.EASE_OUT, Tween.TRANS_ELASTIC)


func _on_mouse_exited() -> void:
	can_drag = true
	Input.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON, Input.CURSOR_ARROW)
	var end_scale: Vector2 = Vector2(1.0, 1.0)
	button_animator.scale_parent(end_scale, base_button_minimum_size, BUTTON_SCALE_TIME, Tween.EASE_OUT, Tween.TRANS_BACK)
