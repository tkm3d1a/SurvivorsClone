extends Area2D
class_name IceSpear

#TODO: Need to set up correct export variables for leveling up
var level: int = 1
var hp: int = 1
var speed: float = 100
var damage: int = 5
var knockback_amount: int = 100
var attack_size: float = 1.0

var target: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO

@onready var player_node: player = get_tree().get_first_node_in_group("player")

signal remove_from_array(object: Area2D)

func _ready() -> void:
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)
	level = player_node.ice_spear_lvl
	match level:
		1:
			hp = 1
			speed = 100
			damage = 5
			knockback_amount = 100
			attack_size = 1.0 * (1 + player_node.spell_size)
		2:
			hp = 1
			speed = 100
			damage = 5
			knockback_amount = 100
			attack_size = 1.0 * (1 + player_node.spell_size)
		3:
			hp = 2
			speed = 100
			damage = 8
			knockback_amount = 100
			attack_size = 1.0 * (1 + player_node.spell_size)
		4:
			hp = 2
			speed = 100
			damage = 8
			knockback_amount = 100
			attack_size = 1.0 * (1 + player_node.spell_size)
		_:
			pass

	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1) * attack_size, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _physics_process(delta: float) -> void:
	position += angle * speed * delta

func enemy_hit(charge: int) -> void:
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array", self)
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()
