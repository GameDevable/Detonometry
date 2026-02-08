class_name UpgradeNode
extends Control
@export var data: UpgradeData 
@export var is_locked: bool = false
var upgrade: Upgrade = null 
var can_purchase: bool = false
var base_position: Vector2 = Vector2.ZERO
var connecting_point: Vector2 = Vector2.ZERO

const UPGRADE_NODE_CAN_AFFORD_THEME = preload("uid://bmi00awkluvkt")
const UPGRADE_NODE_CANT_AFFORD_THEME = preload("uid://cpbqs1ys1nkeb")
const UPGRADE_NODE_MAXED_THEME = preload("uid://b6ntk2x4lk85")

const CANT_AFFORD_PANEL = preload("uid://deq5w1mtbccoi")
const CAN_AFFORD_PANEL = preload("uid://cfd2g0xp8w05i")
const MAXED_PANEL = preload("uid://btycb2sjvvcvy")

const SCALE_TIME: float = 0.6
const EASING_TYPE: Tween.EaseType = Tween.EASE_IN
const TRANSITOIN_TYPE: Tween.TransitionType = Tween.TRANS_BOUNCE

const PURCHASE_SOUND = preload("uid://bgqnendordq35")

@onready var name_display: PanelContainer = $UpgradeDataDisplay/NameDisplay
@onready var name_label: Label = $UpgradeDataDisplay/NameDisplay/NameLabel
@onready var description_label: Label = $UpgradeDataDisplay/NumberDataDisplay/InfoContainer/Labels/DescriptionLabel
@onready var before_after_label: Label = $UpgradeDataDisplay/NumberDataDisplay/InfoContainer/Labels/BeforeAfterLabel
@onready var price_label: Label = $UpgradeDataDisplay/NumberDataDisplay/InfoContainer/Labels/PriceLabel
@onready var purchase_button: Button = $PurchaseButton
@onready var button_animator: Node = $PurchaseButton/ButtonAnimator
@onready var upgrade_data_display: VBoxContainer = $UpgradeDataDisplay
@onready var button_icon: TextureRect = $PurchaseButton/ButtonIcon


func _ready() -> void:
	SignalManager.mouse_dragging.connect(_on_mouse_dragging)
	if data:
		upgrade = Upgrade.new()
		upgrade.data = data
		name_label.text = str(upgrade.get_name())
		before_after_label.text = upgrade.get_before_after()
		description_label.text = upgrade.data.description
		price_label.text = "$" + str(upgrade.get_current_price())
		button_icon.texture = data.icon
		update_theme()
		if not is_locked:
			unlock()
	base_position = purchase_button.position
	connecting_point = purchase_button.global_position + purchase_button.size * 0.25
	button_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT


func is_at_max_tier() -> bool:
	return upgrade.has_reached_max_tier()


func can_purchase_tier(player_points: int) -> bool:
	return not is_locked and upgrade.get_current_price() <= player_points


func purchase_tier(tier: int) -> void:
	StatManager.unlocked_upgrades[data.modify_stat_name] = upgrade
	upgrade.current_purchased_tier = tier 
	upgrade.current_unpurchased_tier = upgrade.current_purchased_tier + 1
	SignalManager.upgrade_purchased.emit(upgrade)
	_update_display()
	if upgrade.has_reached_max_tier():
		can_purchase = false


func unlock() -> void:
	is_locked = false
	SignalManager.upgrade_unlocked.emit(upgrade)
	update_theme()


func update_theme() -> void:
	if not is_locked:
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
		name_display.visible = false


func _update_display() -> void:
	before_after_label.text = upgrade.get_before_after()
	update_theme()
	if upgrade.has_reached_max_tier():
		price_label.text  = "MAXED"
		return
	name_label.text = str(upgrade.data.name)
	price_label.text = "$" + str(upgrade.get_current_price())


func _on_purchase_button_mouse_entered() -> void:
	var base_pitch: float = 1.0
	if not is_locked:
		upgrade_data_display.visible = true
	
	AudioManager.play_sfx(Constants.BUTTON_HOVER_SOUND, 0.0, Constants.ENTER_BUTTON_VOLUME, base_pitch, true, Constants.ENTER_PITCH_RANGE)
	var end_scale: Vector2 = Vector2(1.1, 1.1)
	button_animator.scale_custom_scale_parent(end_scale, SCALE_TIME, Tween.EASE_OUT, Tween.TRANS_ELASTIC)


func _on_purchase_button_mouse_exited() -> void:
	upgrade_data_display.visible = false
	var end_scale: Vector2 = Vector2(1.0, 1.0) * Constants.SPRITE_SCALE
	button_animator.scale_custom_scale_parent(end_scale, SCALE_TIME, Tween.EASE_OUT, Tween.TRANS_BACK)


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
		var volume: float = -6.5
		AudioManager.play_sfx(PURCHASE_SOUND, 0.0, volume, pitch)


func _on_purchase_button_resized() -> void:
	purchase_button.pivot_offset.x = -purchase_button.size.x / 2
