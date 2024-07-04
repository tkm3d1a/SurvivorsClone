extends Area2D
class_name Tornado

#TODO: Need to set up correct export variables for leveling up
var level: int = 1
var hp: int = 999
var speed: float = 125
var damage: int = 5
var knockback_amount: int = 100
var attack_size: float = 1.0

var last_movement: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO
var angle_less: Vector2 = Vector2.ZERO
var angle_more: Vector2 = Vector2.ZERO

var last_move_scalar: int = 500

@onready var player_node: player = get_tree().get_first_node_in_group("player")
@onready var timer_node: Timer = get_node("Timer")

signal remove_from_array(object: Area2D)

func _ready() -> void:
	timer_node.timeout.connect(_on_timer_timeout)
	level = player_node.tornado_lvl
	match level:
		1:
			hp = 999
			speed = 125
			damage = 5
			knockback_amount = 100
			attack_size = 1.0 * (1 + player_node.spell_size)
		2:
			hp = 999
			speed = 125
			damage = 5
			knockback_amount = 100
			attack_size = 1.0 * (1 + player_node.spell_size)
		3:
			hp = 999
			speed = 125
			damage = 5
			knockback_amount = 100
			attack_size = 1.0 * (1 + player_node.spell_size)
		4:
			hp = 999
			speed = 125
			damage = 5
			knockback_amount = 100 + (25)
			attack_size = 1.0 * (1 + player_node.spell_size)
		_:
			pass

	set_angle_less_and_more()
	play_init_tween()
	play_move_tween()

func _physics_process(delta: float) -> void:
	position += angle * speed * delta

func set_angle_less_and_more() -> void:
	var move_to_less: Vector2 = Vector2.ZERO
	var move_to_more: Vector2 = Vector2.ZERO
	match last_movement:
		Vector2.UP, Vector2.DOWN:
			move_to_less = global_position + Vector2(randf_range( - 1, -0.25), last_movement.y) * last_move_scalar
			move_to_more = global_position + Vector2(randf_range(0.25, 1), last_movement.y) * last_move_scalar
		Vector2.RIGHT, Vector2.LEFT:
			move_to_less = global_position + Vector2(last_movement.x, randf_range( - 1, -0.25)) * last_move_scalar
			move_to_more = global_position + Vector2(last_movement.x, randf_range(0.25, 1)) * last_move_scalar
		Vector2(1, 1), Vector2( - 1, 1), Vector2( - 1, -1), Vector2(1, -1):
			move_to_less = global_position + Vector2(last_movement.x, last_movement.y * randf_range(0, 0.75)) * last_move_scalar
			move_to_more = global_position + Vector2(last_movement.x * randf_range(0, 0.75), last_movement.y) * last_move_scalar
		_:
			printerr("Error matching last movement")

	angle_less = global_position.direction_to(move_to_less)
	angle_more = global_position.direction_to(move_to_more)

func play_move_tween() -> void:
	var tween: Tween = create_tween()
	var set_angle: int = randi_range(0, 1)
	if set_angle == 1:
		angle = angle_less
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
	else:
		angle = angle_more
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
	tween.play()

func play_init_tween() -> void:
	var init_tween: Tween = create_tween().set_parallel(true)
	init_tween.tween_property(self, "scale", Vector2(1, 1) * attack_size, 3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	var final_speed: float = speed
	speed = speed / 5
	init_tween.tween_property(self, "speed", final_speed, 6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	init_tween.play()

func _on_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
	queue_free()
