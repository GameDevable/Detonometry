extends Node
var ui_menus: Dictionary[String, Control] = {}
var ui_overlays: Dictionary[String, Control] = {}
var active_overlays: Array[Control] = []
var active_overlay_names: Array[String] = []
var active_menu: Control = null
var ui_canvas: CanvasLayer = null

func set_up_ui(canvas_layer: CanvasLayer) -> void:
	var menus: Control = canvas_layer.get_child(0)
	var overlays: Control = canvas_layer.get_child(1)
	# Sets up menus
	for menu in menus.get_children():
		ui_menus.set(menu.name, menu)
	# Sets up overlays
	for overlay in overlays.get_children():
		ui_overlays.set(overlay.name, overlay)
	ui_canvas = canvas_layer


func show_overlay(overlay_key: String) -> void:
	if not ui_overlays.has(overlay_key):
		push_error("Failed to show overlay. Overlay %s does not exist" % overlay_key)
	var overlay: Control = ui_overlays[overlay_key]
	if overlay.has_method("handle_shown"):
		overlay.handle_shown()
	overlay.visible = true
	active_overlays.push_back(overlay)
	active_overlay_names.push_back(overlay.name)


func hide_overlay(overlay_key: String) -> void:
	if not ui_overlays.has(overlay_key):
		push_error("Failed to hide overlay. Overlay %s does not exist" % overlay_key)
	var overlay: Control = ui_overlays[overlay_key]
	if overlay in active_overlays:
		active_overlays.erase(overlay)
		active_overlay_names.erase(overlay.name)
		overlay.visible = false


func swap_menu(menu_key: String) -> void:
	if menu_key == "None":
		if active_menu:
			active_menu.visible = false
			active_menu = null
			get_tree().paused = false
		return
	if not ui_menus.has(menu_key):
		push_error("Menu %s does not exist")
	var menu: Control = ui_menus[menu_key]
	if active_menu:
		active_menu.visible = false
	if menu.has_method("handle_entered"):
		menu.handle_entered()
	
	get_tree().paused = true
	active_menu = menu
	active_menu.visible = true


func transition_to(menu_key: String) -> void:
	if menu_key == "None":
		SignalManager.session_restarted.emit()
	var transition_effect: Control = ui_canvas.find_child("TransitionEffect", true, true)
	transition_effect.visible = true
	await transition_effect.transition_position(Vector2.ZERO)
	
	swap_menu(menu_key)
	hide_overlay("Hud")
	await transition_effect.transition_position(Vector2(get_viewport().size.x, 0))
	transition_effect.reset()
	
	
