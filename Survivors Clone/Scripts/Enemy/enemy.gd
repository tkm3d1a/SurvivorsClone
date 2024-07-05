extends CharacterBody2D
class_name enemy
# HACK: possible issue with class name not matching scene name in the future with other enemy types?
# TODO: clean up and inherit from a base 'character' class

@export var move_speed: float = 30.0 # common/diff value
@export var hp: int = 10 # common/diff value
@export var knockback_recovery: float = 3.5
@export var experience: int = 1
@export var damage: int

var knockback: Vector2 = Vector2.ZERO
var death_anim_scene: PackedScene = preload ("res://Scenes/Enemy/explosion.tscn")
var gem_scene: PackedScene = preload ("res://Scenes/Objects/experience_gem.tscn")

@onready var target: player = get_tree().get_first_node_in_group("player")
@onready var sprite_node: Sprite2D = $Sprite2D # common
@onready var anim_player_node: AnimationPlayer = get_node("AnimationPlayer")
@onready var sound_hit: AudioStreamPlayer = $snd_hit
@onready var loot_base: Node2D = get_tree().get_first_node_in_group("loot")
@onready var hitbox_node: hitbox = get_node("Hitbox")

signal remove_from_array(object: Node2D)

func _ready() -> void:
	anim_player_node.play("walk")
	hitbox_node.damage = damage

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
	spawn_gem()
	queue_free()

func spawn_gem() -> void:
	var gem_node: ExperienceGem = gem_scene.instantiate()
	gem_node.global_position = global_position
	gem_node.experience_value = experience
	loot_base.call_deferred("add_child", gem_node)

func _on_hurtbox_hurt(rcvd_damage: int, angle: Vector2, knockback_amount: int) -> void: # common-ish
	hp -= rcvd_damage
	knockback = angle * knockback_amount
	if hp <= 0:
		death()
	else:
		sound_hit.play()
