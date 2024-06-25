class_name hurtbox
extends Area2D

@export_enum("Cooldown", "HitOnce", "DisableHitBox") var hurt_box_type: int = 0

@onready var collision_node: CollisionShape2D = $CollisionShape2D
@onready var timer_node: Timer = $Timer

var hit_once_array: Array = []

signal hurt(damage: int)

func _on_area_entered(area: Area2D) -> void: # autolinked signal from editor
	if area.is_in_group("attack"):
		if not area.get("damage") == null:
			match hurt_box_type:
				0: # Cooldown
					collision_node.call_deferred("set", "disabled", true)
					timer_node.start()
				1: # HitOnce
					if hit_once_array.has(area) == false:
						hit_once_array.append(area)
						if area.has_signal("remove_from_array"):
							if not area.is_connected("remove_from_array", Callable(self,"remove_from_list")):
								area.connect("remove_from_array",Callable(self, "remove_from_list"))
					else:
						return
				2: # DisableHitBox
					if area.has_method("temp_disable"):
						area.temp_disable()
				_:
					pass
			var damage: int = area.damage
			var angle: Vector2 = Vector2.ZERO
			var knockback: int = 1

			if not area.get("angle") == null:
				angle = area.angle

			if not area.get("knockback_amount") == null:
				knockback = area.knockback_amount
			
			emit_signal("hurt", damage, angle, knockback)
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)

func remove_from_list(object:Area2D) -> void:
	if hit_once_array.has(object):
		hit_once_array.erase(object)

func _on_timer_timeout() -> void: # autolinked signal from editor
	collision_node.call_deferred("set", "disabled", false)
