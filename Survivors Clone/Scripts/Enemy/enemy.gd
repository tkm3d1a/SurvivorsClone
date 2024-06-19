class_name enemy
extends CharacterBody2D

@export var move_speed: float = 30.0

@onready var target: player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
    printerr("Script not complete: " + name)

func _physics_process(_delta: float) -> void:
    var direction_to_player: Vector2 = global_position.direction_to(target.global_position)
    velocity = direction_to_player * move_speed
    move_and_slide()