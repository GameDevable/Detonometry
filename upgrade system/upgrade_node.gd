class_name UpgradeNode
extends Control
@export var data: UpgradeData
@export var is_locked: bool = true
@export var is_demo: bool = true
const UPGRADE_NODE_CAN_AFFORD_THEME = preload("uid://bmi00awkluvkt")
const UPGRADE_NODE_CANT_AFFORD_THEME = preload("uid://cpbqs1ys1nkeb")
const UPGRADE_NODE_MAXED_THEME = preload("uid://b6ntk2x4lk85")

const CANT_AFFORD_PANEL = preload("uid://deq5w1mtbccoi")
const CAN_AFFORD_PANEL = preload("uid://cfd2g0xp8w05i")
const MAXED_PANEL = preload("uid://btycb2sjvvcvy")
const UPGRADE_NODE_LOCKED_THEME = preload("uid://brntsa6831d7c")

const SCALE_TIME: float = 0.6
const EASING_TYPE: Tween.EaseType = Tween.EASE_IN
const TRANSITOIN_TYPE: Tween.TransitionType = Tween.TRANS_BOUNCE
const PURCHASE_SOUND = preload("uid://bjfprnmwdmsfx")

const NORMAL_LOCK_TEXTURE = preload("uid://bbh311wdplytv")
const HOVER_LOCK_TEXTURE: Texture2D = preload("uid://cexmjh73ifghx")
const PRESSED_LOCK_TEXTURE = preload("uid://ddk65fi0yfwe0")

var upgrade: Upgrade = null
var can_purchase: bool = false
var base_position: Vector2 = Vector2.ZERO
var base_display_min_size: Vector2 = Vector2.ZERO
var base_display_position: Vector2 = Vector2.ZERO

@onready var name_display: PanelContainer = $UpgradeDataDisplay/DisplayBackground/VBoxContainer/NamePanel

@onready var name_label: Label = $UpgradeDataDisplay/DisplayBackground/VBoxContainer/NamePanel/NameMargins/NameLabel
@onready var description_label: Label = $UpgradeDataDisplay/DisplayBackground/VBoxContainer/InfoContainer/Labels/DescriptionLabel
@onready var before_after_label: Label = $UpgradeDataDisplay/DisplayBackground/VBoxContainer/InfoContainer/Labels/BeforeAfterLabel
@onready var level_label: Label = $UpgradeDataDisplay/DisplayBackground/VBoxContainer/InfoContainer/Labels/LevelLabel
@onready var price_label: Label = $UpgradeDataDisplay/DisplayBackground/VBoxContainer/InfoContainer/Labels/PriceLabel


@onready var purchase_button: Button = $PurchaseButton
@onready var upgrade_data_display: VBoxContainer = $UpgradeDataDisplay

@onready var button_icon: TextureRect = $PurchaseButton/ButtonIcon
@onready var lock_icon: TextureRect = $PurchaseButton/LockIcon

@onready var button_scale_effect: UiEffectComponent = $PurchaseButton/ButtonScaleEffect
@onready var display_scale_effect: UiEffectComponent = $UpgradeDataDisplay/DisplayScaleEffect


func _ready() -> void:
	SignalManager.mouse_dragging.connect(_on_mouse_dragging)
	if data:
		upgrade = Upgrade.new()
		upgrade.data = data
		name_label.text = str(upgrade.get_name())
		before_after_label.text = "??? -> ???"
		description_label.text = "????????????????????????"
		price_label.text = "???"
		button_icon.texture = data.icon
		update_theme()
		if not is_locked:
			unlock()
	base_position = purchase_button.position
	base_display_min_size = upgrade_data_display.custom_minimum_size
	button_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	purchase_button.icon = null
	base_display_position = upgrade_data_display.position


func is_at_max_tier() -> bool:
	return upgrade.has_reached_max_tier()


func can_purchase_tier(player_points: int) -> bool:
	return not is_locked and upgrade.get_current_price() <= player_points


func purchase_tier(tier: int) -> void:
	advance_tier(tier)
	SignalManager.upgrade_purchased.emit(upgrade)
	SaveManager.save_game()


func advance_tier(current_tier: int) -> void:
	upgrade.current_purchased_tier = current_tier 
	upgrade.current_unpurchased_tier = upgrade.current_purchased_tier + 1
	StatManager.unlocked_upgrades[data.modify_stat_name] = upgrade
	SignalManager.upgrade_advanced.emit(upgrade)
	_update_display()
	if upgrade.has_reached_max_tier():
		can_purchase = false


func unlock() -> void:
	is_locked = false
	SignalManager.upgrade_unlocked.emit(upgrade)
	lock_icon.visible = false
	var intensity: float = 1.5 # >1 brightens, <1 darkens
	modulate.r = intensity
	modulate.g = intensity
	modulate.b = intensity
	upgrade_data_display.modulate.r = 1
	upgrade_data_display.modulate.g = 1
	upgrade_data_display.modulate.b = 1
	update_theme()
	_update_display()


func lock() -> void:
	is_locked = true
	lock_icon.visible = true
	SignalManager.upgrade_locked.emit(upgrade)
	var intensity: int = 1 # >1 brightens, <1 darkens
	modulate.r =  intensity
	modulate.g =  intensity
	modulate.b =  intensity
	update_theme()
	_update_display()


func update_theme() -> void:
	if not is_locked:
		name_display.visible  = true
		if upgrade.has_reached_max_tier():
			purchase_button.theme = UPGRADE_NODE_MAXED_THEME
			name_display.theme = MAXED_PANEL
			price_label.add_theme_color_override("font_color", Color("ffe26f"))
			return
		elif can_purchase:
			name_display.theme = CAN_AFFORD_PANEL
			purchase_button.theme = UPGRADE_NODE_CAN_AFFORD_THEME
			price_label.add_theme_color_override("font_color", Color("00fa82"))
		else:
			name_display.theme = CANT_AFFORD_PANEL
			purchase_button.theme = UPGRADE_NODE_CANT_AFFORD_THEME
			price_label.add_theme_color_override("font_color", Color("ff2323"))
	else:
		name_display.visible = true
		purchase_button.theme = UPGRADE_NODE_LOCKED_THEME


func _update_display() -> void:
	before_after_label.text = upgrade.get_before_after()
	update_theme()
	if upgrade.has_reached_max_tier():
		price_label.text  = "MAXED"
		level_label.text = "Lv " + str(upgrade.current_purchased_tier) + "/" + str(upgrade.current_purchased_tier)
		return
	if is_locked:
		pass
	name_label.text = str(upgrade.data.name)
	price_label.text = "$" + str(upgrade.get_current_price())
	description_label.text = upgrade.data.description
	level_label.text = "Lv " + str(upgrade.current_purchased_tier) + "/" + str(upgrade.data.tier_modifiers.size())


func _on_purchase_button_mouse_entered() -> void:
	if global_position.y < get_viewport_rect().size.y / 4:
		upgrade_data_display.position.y = -base_display_position.y - 10
	else:
		upgrade_data_display.position.y = base_display_position.y - 10
	var base_pitch: float = 1.0
	upgrade_data_display.visible = true
	EffectManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)
	lock_icon.texture = HOVER_LOCK_TEXTURE
	var end_scale: Vector2 = Vector2(0.6, 0.6)
	button_scale_effect.scale_ui(purchase_button.scale, end_scale)
	display_scale_effect.scale_ui(Vector2.ZERO, Vector2(1.0, 1.0))


func _on_purchase_button_mouse_exited() -> void:
	lock_icon.texture = NORMAL_LOCK_TEXTURE
	var end_scale: Vector2 = Vector2(0.5, 0.5) 
	button_scale_effect.scale_ui(purchase_button.scale, end_scale, Tween.TRANS_EXPO)
	display_scale_effect.scale_ui(purchase_button.scale, Vector2(0.0, 0.0))
	await display_scale_effect.tween.finished
	upgrade_data_display.visible = false


func _on_mouse_dragging(is_dragging: bool) -> void:
	if is_dragging and not purchase_button.is_hovered():
		purchase_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		
		purchase_button.mouse_filter = Control.MOUSE_FILTER_STOP


func _on_purchase_button_pressed() -> void:
	if can_purchase:
		# Purchases the tier above 
		purchase_tier(upgrade.current_unpurchased_tier)
		var pitch: float = 0.25
		var volume: float = -14
		EffectManager.play_sfx(PURCHASE_SOUND, 0.0, volume, pitch)
	EffectManager.play_sfx(Constants.BUTTON_CLICK_SOUND, 0.0, Constants.BUTTON_CLICK_VOLUME, Constants.BUTTON_CLICK_PITCH)


func _on_purchase_button_button_up() -> void:
	lock_icon.texture = HOVER_LOCK_TEXTURE


func _on_purchase_button_button_down() -> void:
	lock_icon.texture = PRESSED_LOCK_TEXTURE
