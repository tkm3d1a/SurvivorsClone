class_name player
extends CharacterBody2D

@export var move_speed: float = 75.0

func _ready() -> void:
    printerr("Script not complete: " + name)

func _physics_process(_delta: float) -> void:
    movement()

func movement() -> void:
    # TODO: Update to implement globals for inputs
    var x_move_input: float = Input.get_action_strength("MoveRight") - Input.get_action_strength("MoveLeft")
    var y_move_input: float = Input.get_action_strength("MoveDown") - Input.get_action_strength("MoveUp")
    var move_input: Vector2 = Vector2(x_move_input, y_move_input)

    velocity = move_input.normalized() * move_speed

    move_and_slide()