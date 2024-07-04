extends Area2D
class_name Javelin

#TODO: Need to set up correct export variables for leveling up
var level: int = 1
var hp: int = 999
var speed: float = 200
var damage: int = 10
var knockback_amount: int = 100
var paths: int = 1
var attack_size: float = 1.0

var attack_speed: float = 4.0
var angle: Vector2 = Vector2.ZERO

var target: Vector2 = Vector2.ZERO
var target_array: Array[Vector2] = []
var reset_pos: Vector2 = Vector2.ZERO

var sprite_jav_reg: CompressedTexture2D = preload ("res://Assets/Textures/Items/Weapons/javelin_3_new.png")
var sprite_jav_atk: CompressedTexture2D = preload ("res://Assets/Textures/Items/Weapons/javelin_3_new_attack.png")

@onready var player_node: player = get_tree().get_first_node_in_group("player")
@onready var sprite_node: Sprite2D = get_node("Sprite2D")
@onready var collision_node: CollisionShape2D = get_node("CollisionShape2D")
@onready var atk_timer_node: Timer = get_node("AttackTimer")
@onready var change_dir_timer: Timer = get_node("ChangeDirTimer")
@onready var reset_timer: Timer = get_node("ResetPosTimer")
@onready var stream_node: AudioStreamPlayer2D = get_node("snd_play")

signal remove_from_array(object: Area2D)

func _ready() -> void:
	update_javelin()
	move_jav_no_target()

func _physics_process(delta: float) -> void:
	if target_array.size() > 0:
		position += angle * speed * delta
	else:
		var player_angle: Vector2 = global_position.direction_to(reset_pos)
		var distance_dif: Vector2 = player_node.global_position
		var return_speed: int = 20
		if abs(distance_dif.x) > 500 or abs(distance_dif.y) > 500:
			return_speed = 100
		position += player_angle * return_speed * delta
		rotation = global_position.direction_to(player_node.global_position).angle() + deg_to_rad(135)

func update_javelin() -> void:
	level = player_node.javelin_lvl
	match level:
		1:
			hp = 999
			speed = 200
			damage = 10
			knockback_amount = 100
			attack_size = 1.0 * (1 + player_node.spell_size)
			attack_speed = 4.0 * (1 - player_node.spell_cooldown)
		2:
			hp = 999
			speed = 200
			damage = 10
			knockback_amount = 100
			attack_size = 1.0 * (1 + player_node.spell_size)
			attack_speed = 4.0 * (1 - player_node.spell_cooldown)
		3:
			hp = 999
			speed = 200
			damage = 10
			knockback_amount = 100
			attack_size = 1.0 * (1 + player_node.spell_size)
			attack_speed = 4.0 * (1 - player_node.spell_cooldown)
		4:
			hp = 999
			speed = 200
			damage = 15
			knockback_amount = 120
			attack_size = 1.0 * (1 + player_node.spell_size)
			attack_speed = 4.0 * (1 - player_node.spell_cooldown)
		_:
			pass
	
	scale = Vector2(1.0, 1.0) * attack_size
	atk_timer_node.wait_time = attack_speed

func add_paths() -> void:
	stream_node.play()
	emit_signal("remove_from_array", self)
	target_array.clear()
	var counter: int = 0
	while counter < paths:
		var new_path: Vector2 = player_node.get_random_target()
		target_array.append(new_path)
		counter += 1
		enable_attack(true)
	target = target_array[0]
	process_path()

func process_path() -> void:
	angle = global_position.direction_to(target)
	
	var tween: Tween = create_tween()
	var new_rot_degrees: float = angle.angle() + deg_to_rad(135)
	tween.tween_property(self, "rotation", new_rot_degrees, 0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	
	change_dir_timer.start()

func enable_attack(enabled: bool=true) -> void:
	if enabled:
		collision_node.call_deferred("set", "disabled", false)
		sprite_node.texture = sprite_jav_atk
	else:
		collision_node.call_deferred("set", "disabled", true)
		sprite_node.texture = sprite_jav_reg

func move_jav_no_target() -> void:
	var choose_dir: int = randi() % 4
	reset_pos = player_node.global_position
	match choose_dir:
		0:
			reset_pos.x += randi_range(20, 70)
		1:
			reset_pos.x -= randi_range(20, 70)
		2:
			reset_pos.y += randi_range(20, 70)
		3:
			reset_pos.y -= randi_range(20, 70)
		_:
			pass

func _on_attack_timer_timeout() -> void:
	add_paths()

func _on_change_dir_timer_timeout() -> void:
	if target_array.size() > 0:
		target_array.remove_at(0)
		if target_array.size() > 0:
			target = target_array[0]
			process_path()
			stream_node.play()
			emit_signal("remove_from_array", self)
		else:
			enable_attack(false)
	else:
		change_dir_timer.stop()
		atk_timer_node.start()

func _on_reset_pos_timer_timeout() -> void:
	move_jav_no_target()
