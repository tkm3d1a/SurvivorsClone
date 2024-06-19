class_name enemy
# HACK: possible issue with class name not matching scene name in the future with other enemy types?
# TODO: clean up and inherit from a base 'character' class
extends CharacterBody2D

@export var move_speed: float = 30.0 # common

@onready var target: player = get_tree().get_first_node_in_group("player")
@onready var sprite_node: Sprite2D = $Sprite2D # common
@onready var anim_player_node: AnimationPlayer = get_node("AnimationPlayer")

func _ready() -> void:
    anim_player_node.play("walk")

    # TODO: Remove when script complete for mvp
    printerr("Script not complete: " + name)

func _physics_process(_delta: float) -> void:
    # TODO: Create function for movement
    var direction_to_player: Vector2 = global_position.direction_to(target.global_position)
    velocity = direction_to_player * move_speed
    flip_sprite(direction_to_player.x)

    move_and_slide()

func flip_sprite(move_x_result: float) -> void: # common
    if move_x_result > 0:
        sprite_node.flip_h = true
    elif move_x_result < 0:
        sprite_node.flip_h = false