class_name enemy
# HACK: possible issue with class name not matching scene name in the future with other enemy types?
# TODO: clean up and inherit from a base 'character' class
extends CharacterBody2D

@export var move_speed: float = 30.0 # common/diff value
@export var hp: int = 10 # common/diff value
@export var knockback_recovery: float = 3.5

var knockback: Vector2 = Vector2.ZERO
var death_anim_scene: PackedScene = preload ("res://Scenes/Enemy/explosion.tscn")

@onready var target: player = get_tree().get_first_node_in_group("player")
@onready var sprite_node: Sprite2D = $Sprite2D # common
@onready var anim_player_node: AnimationPlayer = get_node("AnimationPlayer")
@onready var sound_hit: AudioStreamPlayer = $snd_hit

signal remove_from_array(object: Node2D)

func _ready() -> void:
	anim_player_node.play("walk")

	# TODO: Remove when script complete for mvp
	printerr("Script not complete: " + name)

func _physics_process(_delta: float) -> void:
	# TODO: Create function for movement
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction_to_player: Vector2 = global_position.direction_to(target.global_position)
	velocity = direction_to_player * move_speed
	velocity += knockback
	flip_sprite(direction_to_player.x)

	move_and_slide()

func flip_sprite(move_x_result: float) -> void: # common
	if move_x_result > 0:
		sprite_node.flip_h = true
	elif move_x_result < 0:
		sprite_node.flip_h = false

func death() -> void:
	emit_signal("remove_from_array", self)
	var death_anim: Explosion = death_anim_scene.instantiate()
	death_anim.scale = sprite_node.scale
	death_anim.global_position = global_position
	get_parent().call_deferred("add_child", death_anim)
	queue_free()

func _on_hurtbox_hurt(damage: int, angle: Vector2, knockback_amount: int) -> void: # common-ish
	hp -= damage
	knockback = angle * knockback_amount
	if hp <= 0:
		death()
	else:
		sound_hit.play()
