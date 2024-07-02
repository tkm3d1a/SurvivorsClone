extends Area2D
class_name ExperienceGem

@export var experience_value: int = 1

var spr_green: CompressedTexture2D = preload ("res://Assets/Textures/Items/Gems/Gem_green.png")
var spr_red: CompressedTexture2D = preload ("res://Assets/Textures/Items/Gems/Gem_red.png")
var spr_blue: CompressedTexture2D = preload ("res://Assets/Textures/Items/Gems/Gem_blue.png")

var target: Node2D = null
var speed: float = -0.5

@onready var sprite_node: Sprite2D = get_node("Sprite2D")
@onready var collision_node: CollisionShape2D = get_node("CollisionShape2D")
@onready var stream_node: AudioStreamPlayer = get_node("snd_collected")

func _ready() -> void:
	if experience_value < 5:
		return
	elif experience_value < 25:
		sprite_node.texture = spr_blue
	else:
		sprite_node.texture = spr_red
	
	stream_node.finished.connect(_on_audio_finished)

func _physics_process(delta: float) -> void:
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2.0 * delta

func collect() -> int:
	stream_node.play()
	collision_node.call_deferred("set", "disabled", true)
	sprite_node.visible = false
	return experience_value

func _on_audio_finished() -> void:
	queue_free()