class_name hurtbox
extends Area2D

@export_enum("Cooldown", "HitOnce", "DisableHitBox") var hurt_box_type: int = 0

@onready var collision_node: CollisionShape2D = $CollisionShape2D
@onready var timer_node: Timer = $Timer

signal hurt(damage: int)

func _on_area_entered(area: Area2D) -> void: # autolinked signal from editor
	if area.is_in_group("attack"):
		if not area.get("damage") == null:
			match hurt_box_type:
				0: # Cooldown
					collision_node.call_deferred("set", "disabled", true)
					timer_node.start()
				1: # HitOnce
					pass
				2: # DisableHitBox
					if area.has_method("temp_disable"):
						area.temp_disable()
				_:
					pass
			var damage: int = area.damage
			emit_signal("hurt", damage)
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)

func _on_timer_timeout() -> void: # autolinked signal from editor
	collision_node.call_deferred("set", "disabled", false)
