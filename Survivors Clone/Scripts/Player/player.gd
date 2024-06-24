class_name player
# TODO: clean up and inherit from a base 'character' class
extends CharacterBody2D

@export var move_speed: float = 75.0 # common
@export var hp: int = 80 # common

# Attacks
var ice_spear: PackedScene = preload ("res://Scenes/Player/ice_spear.tscn")

# Attack Nodes
@onready var ice_spear_timer: Timer = get_node("Attack/IceSpearTimer")
@onready var ice_spear_atk_timer: Timer = get_node("Attack/IceSpearTimer/IceSpearAttackTimer")

# IceSpear
var ice_spear_ammo: int = 0
var ice_spear_base_ammo: int = 1
var ice_spear_atk_spd: float = 1.5
var ice_spear_lvl: int = 1

# Enemy Related
var enemy_close: Array[Node2D] = []

@onready var sprite_node: Sprite2D = $Sprite2D # common
@onready var walk_timer_node: Timer = get_node("WalkTimer")

func _ready() -> void:
	# TODO: Remove when script complete for mvp
	attack()
	printerr("Script not complete: " + name)

func _physics_process(_delta: float) -> void:
	movement()

func movement() -> void:
	# TODO: Update to implement globals for inputs
	var x_move_input: float = Input.get_action_strength("MoveRight") - Input.get_action_strength("MoveLeft")
	var y_move_input: float = Input.get_action_strength("MoveDown") - Input.get_action_strength("MoveUp")
	var move_input: Vector2 = Vector2(x_move_input, y_move_input)
	flip_sprite(move_input.x)
	animate_sprite(move_input)

	velocity = move_input.normalized() * move_speed
	move_and_slide()

func flip_sprite(move_x_result: float) -> void: # common
	if move_x_result > 0:
		sprite_node.flip_h = true
	elif move_x_result < 0:
		sprite_node.flip_h = false

func animate_sprite(move_result: Vector2) -> void:
	if move_result != Vector2.ZERO:
		if walk_timer_node.is_stopped():
			if sprite_node.frame >= sprite_node.hframes - 1:
				sprite_node.frame = 0
			else:
				sprite_node.frame += 1
			walk_timer_node.start()

func attack() -> void:
	if ice_spear_lvl > 0:
		ice_spear_timer.wait_time = ice_spear_atk_spd
		if ice_spear_timer.is_stopped():
			ice_spear_timer.start()

func get_random_target() -> Vector2:
	if not enemy_close.is_empty():
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP

func _on_hurtbox_hurt(damage: int) -> void: # common-ish
	hp -= damage
	print(hp)

func _on_ice_spear_timer_timeout() -> void:
	ice_spear_ammo += ice_spear_base_ammo
	ice_spear_atk_timer.start()

func _on_ice_spear_attack_timer_timeout() -> void:
	if ice_spear_ammo > 0:
		var ice_spear_node: IceSpear = ice_spear.instantiate()
		ice_spear_node.position = position
		ice_spear_node.target = get_random_target()
		ice_spear_node.level = ice_spear_lvl
		add_child(ice_spear_node)
		ice_spear_ammo -= 1
		if ice_spear_ammo > 0:
			ice_spear_atk_timer.start()
		else:
			ice_spear_atk_timer.stop()

func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if enemy_close.has(body):
		enemy_close.erase(body)
