extends Area2D
class_name hitbox

@export var damage: int = 1

@onready var collision_node: CollisionShape2D = $CollisionShape2D
@onready var timer_node: Timer = $Timer

func temp_disable() -> void:
	collision_node.call_deferred("set", "disabled", true)
	timer_node.start()

func _on_timer_timeout() -> void: # autolinked signal from editor
	collision_node.call_deferred("set", "disabled", false)
