extends Control
var is_dragging: bool = false
var can_drag: bool = true
var mouse_inside_button: bool = false
var base_button_minimum_size: Vector2 = Vector2.ZERO
const DRAG_SPEED: float = 1.1
const BUTTON_SCALE_TIME: float = 0.4
const MIN_SCALE: Vector2 = Vector2(0.5, 0.5)
const MAX_SCALE: Vector2 = Vector2(1.0, 1.0)
const SCROLL_SPEED: float = 1.0
# Left, right, Bottom, Top
const DRAG_BOUNDS: Array[float] = [-250, 250, -600, 275]
@onready var points_label: Label = $PointsLabel
@onready var upgrade_nodes: Control = $DraggableNodes/UpgradeNodes
@onready var draggable_nodes: Control = $DraggableNodes

@onready var settings_button: Button = $Buttons/SettingsButton
@onready var back_to_game_button: Button = $Buttons/ContinueButton
@onready var main_menu_button: Button = $Buttons/MainMenuButton
@onready var background_panel: Panel = $BackgroundPanel


func _ready() -> void:
	visible = false
	#SignalManager.points_changed.connect(_on_points_changed)
	SignalManager.upgrade_unlocked.connect(func(_upgrade: Upgrade) -> void:
		var purchasable_node_count: int = _update_buttons(upgrade_nodes, GameManager.total_points)
		SignalManager.purchase_amount_changed.emit(purchasable_node_count)
		)
	
	# Recursively loops through the buttons
	if upgrade_nodes:
		_set_up_buttons(upgrade_nodes)


func _input(event: InputEvent) -> void:
	if not UiManager.active_menu:
		return
	if event is InputEventMouseButton :
		var mouse_event = event as InputEventMouseButton
		if mouse_event.pressed:
			if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom(1)
			elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom(-1)

		if _check_drag():
			await get_tree().create_timer(0.1).timeout
			if _check_drag():
				is_dragging = true
				SignalManager.mouse_dragging.emit(is_dragging)
				UiManager.set_custom_mouse_cursor(Constants.DRAG_HAND_CURSOR_ICON)
		if Input.is_action_just_released("drag") and is_dragging and UiManager.active_menu.name == name:
			is_dragging = false
			SignalManager.mouse_dragging.emit(is_dragging)
			
			UiManager.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON)

	if event is InputEventMouseMotion:
		if is_dragging:
			event = event as InputEventMouseMotion
			# Updates the position of basically the hub based on the speed and direction of the mouse
			draggable_nodes.position += event.relative * DRAG_SPEED
			draggable_nodes.position.x = clamp(draggable_nodes.position.x, DRAG_BOUNDS[0], DRAG_BOUNDS[1])
			draggable_nodes.position.y = clamp(draggable_nodes.position.y, DRAG_BOUNDS[2], DRAG_BOUNDS[3])


func save() -> Dictionary:
	var unlocked_upgrades_data: Dictionary = {}
	
	for upgrade in StatManager.unlocked_upgrades.values():
		upgrade = upgrade as Upgrade
		unlocked_upgrades_data[upgrade.data.modify_stat_name] = upgrade.save()
	return {"unlocked_upgrades" : unlocked_upgrades_data}


func load_save_data(data: Dictionary) -> void:
	var unlocked_upgrade_data = data["unlocked_upgrades"]
	for saved_upgrade_data in unlocked_upgrade_data:
		var upgrade: Upgrade = Upgrade.new()
		upgrade.load_saved_data(data["unlocked_upgrades"][saved_upgrade_data])
		StatManager.unlocked_upgrades[upgrade.data.modify_stat_name] = upgrade
	# Loops through the upgrade holders to access and save the actual nodes.
	if not upgrade_nodes:
		return
	for upgrade_container in upgrade_nodes.get_children():
			
		for upgrade_node in upgrade_container.get_children():
			
			var upgrade_name: String = upgrade_node.upgrade.data.modify_stat_name
			if upgrade_name in StatManager.unlocked_upgrades.keys():
				upgrade_node = upgrade_node as UpgradeNode
				upgrade_node.upgrade = StatManager.unlocked_upgrades[upgrade_name]
				# Since unlocking it already updates the display we are good!
				upgrade_node.unlock()
				# To update the connectors
				SignalManager.upgrade_advanced.emit(upgrade_node.upgrade)


func reset() -> void:
	pass


func handle_entered() -> void:
	UiManager.set_mouse_cursor_visible(true)
	UiManager.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON)
	UiManager.set_progress_visible(false)
	points_label.text = "$" + str(GameManager.total_points)
	draggable_nodes.position = Vector2.ZERO


func _zoom(direction: int) -> void:
	var zoom_change: float = SCROLL_SPEED * 0.05
	var new_scale = draggable_nodes.scale + Vector2.ONE * direction * zoom_change
	new_scale.x = clamp(new_scale.x, MIN_SCALE.x, MAX_SCALE.x)
	new_scale.y = clamp(new_scale.y, MIN_SCALE.y, MAX_SCALE.y)
	draggable_nodes.scale = new_scale
	#background_panel.scale = new_scale
	


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

	# Recursively finds the upgrade nodes and adds the number of upgrades that can be purchased to a variable
	var purchasable_node_count: int = _update_buttons(upgrade_nodes, value)
	SignalManager.purchase_amount_changed.emit(purchasable_node_count)


func _check_drag() -> bool:
	return Input.is_action_pressed("drag") and can_drag and UiManager.active_menu.name == name


func _update_buttons(parent_node: Control, points_value: int) -> int:
	if not parent_node:
		return 0
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




func _on_mouse_entered() -> void:
	can_drag = false
	var base_pitch: float = 1.0
	EffectManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)


func _on_mouse_exited() -> void:
	can_drag = true
	UiManager.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON)

func _on_main_menu_button_mouse_entered() -> void:
	can_drag = false
	mouse_inside_button = true
	var base_pitch: float = 1.0
	EffectManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)
	var end_scale: Vector2 = Vector2(1.1, 1.1)
	$BackgroundPanel/MainMenuButton/ButtonScaleEffect.scale_ui(main_menu_button.scale, end_scale)


func _on_main_menu_button_mouse_exited() -> void:
	can_drag = true
	UiManager.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON)
	var end_scale: Vector2 = Vector2(1.0, 1.0)
	$BackgroundPanel/MainMenuButton/ButtonScaleEffect.scale_ui(main_menu_button.scale, end_scale, Tween.TRANS_EXPO)


func _on_settings_button_mouse_entered() -> void:
	can_drag = false
	var base_pitch: float = 1.0
	EffectManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)
	var end_scale: Vector2 = Vector2(1.1, 1.1)
	$BackgroundPanel/SettingsButton/ButtonScaleEffect.scale_ui(settings_button.scale, end_scale)


func _on_settings_button_mouse_exited() -> void:
	can_drag = true
	UiManager.set_custom_mouse_cursor(Constants.NORMAL_CURSOR_ICON)
	var end_scale: Vector2 = Vector2(1.0, 1.0)
	$BackgroundPanel/SettingsButton/ButtonScaleEffect.scale_ui(settings_button.scale, end_scale, Tween.TRANS_EXPO)
