class_name Upgrade
extends RefCounted
var data: UpgradeData
var current_unpurchased_tier: int = 1
var current_purchased_tier: int = 0
const PRICE_SCALE: float = 1.5

func has_reached_max_tier() -> bool:
	return current_purchased_tier >= data.tier_modifiers.size() 
 

func get_before_after() -> String:
	if has_reached_max_tier():
		return str(data.tier_modifiers[current_purchased_tier - 1]) + data.extra_character
	var first_value: String = ""
	var arrow: String = " -> "
	var second_value: String = ""
	
	if current_purchased_tier == 0:
		first_value = str(data.base_value)
	else:
		first_value = str(data.tier_modifiers[current_purchased_tier - 1])
	second_value = str(data.tier_modifiers[current_unpurchased_tier - 1])
	return first_value + data.extra_character + arrow + second_value + data.extra_character


func get_current_price() -> int:
	return _calculate_price(data.base_price, current_unpurchased_tier, data.custom_price_scale)


func get_previous_price() -> int:
	return _calculate_price(data.base_price, current_purchased_tier, data.custom_price_scale)


func get_name() -> String:
	return data.name


func get_upgraded_stat() -> float:
	var current_tier_index: int = current_purchased_tier - 1
	return data.tier_modifiers[current_tier_index]
	

func _calculate_price(base_value: int, n: int, price_scale: float) -> int:
	return int(base_value * pow(price_scale, n - 1))


func save() -> Dictionary:
	return {"upgrade_data" : data.resource_path, "current_purchased_tier" : current_purchased_tier}


func load_saved_data(save_data: Dictionary) -> void:
	data = load(save_data["upgrade_data"])
	current_purchased_tier = save_data["current_purchased_tier"]
	current_unpurchased_tier = current_purchased_tier + 1
