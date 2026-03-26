extends CharacterBody2D


@export var SPEED = 450.0
var movement_direction: Vector2 = Vector2.ZERO
var resistance: int = 1
var current_hit_count: int = 0

@onready var hitbox: Hitbox = $Hitbox

func _ready() -> void:
	resistance = int(StatManager.get_special_modifier_stat("piercing_value"))
	hitbox.damage = int(StatManager.get_special_modifier_stat("dart_damage"))


func _physics_process(_delta: float) -> void:
	velocity = movement_direction * SPEED
	move_and_slide()


func _handle_destruction() -> void:
	queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is not Bomb:
		current_hit_count += 1
	if current_hit_count > resistance:
		_handle_destruction()
