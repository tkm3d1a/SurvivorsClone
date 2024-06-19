class_name player
# TODO: clean up and inherit from a base 'character' class
extends CharacterBody2D

@export var move_speed: float = 75.0 # common
@export var hp: int = 80 # common

@onready var sprite_node: Sprite2D = $Sprite2D # common
@onready var walk_timer_node: Timer = get_node("WalkTimer")

func _ready() -> void:
	# TODO: Remove when script complete for mvp
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

func _on_hurtbox_hurt(damage: int) -> void: # common-ish
	hp -= damage
	print(hp)
