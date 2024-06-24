class_name enemySpawner
# Fixme: class names need to be standardized - causing issues in coding but not breaking anything currently
extends Node2D

@export var spawns: Array[spawn_info] = []

@onready var player_node: player = get_tree().get_first_node_in_group("player")

var time: int = 0

func _on_timer_timeout() -> void:
	time += 1
	var enemy_spawns: Array[spawn_info] = spawns
	for item: spawn_info in enemy_spawns:
		if time >= item.time_start and time <= item.time_end:
			if item.spawn_delay_counter < item.enemy_spawn_delay:
				item.spawn_delay_counter += 1
			else:
				item.spawn_delay_counter = 0
				var new_enemy: PackedScene = item.enemy_resource
				var counter: int = 0
				while counter < item.enemy_num:
					var enemy_spawned: Node = new_enemy.instantiate()
					enemy_spawned.global_position = get_rand_position()
					add_child(enemy_spawned)
					counter += 1

func get_rand_position() -> Vector2:
	var vp_rec: Vector2 = get_viewport_rect().size * randf_range(1.1, 1.4)
	var top_left: Vector2 = Vector2(player_node.global_position.x - vp_rec.x / 2, player_node.global_position.y - vp_rec.y / 2)
	var top_right: Vector2 = Vector2(player_node.global_position.x + vp_rec.x / 2, player_node.global_position.y - vp_rec.y / 2)
	var bottom_left: Vector2 = Vector2(player_node.global_position.x - vp_rec.x / 2, player_node.global_position.y + vp_rec.y / 2)
	var bottom_right: Vector2 = Vector2(player_node.global_position.x + vp_rec.x / 2, player_node.global_position.y + vp_rec.y / 2)
	var pos_side: String = ["up", "down", "left", "right"].pick_random()
	var spawn_pos1: Vector2 = Vector2.ZERO
	var spawn_pos2: Vector2 = Vector2.ZERO

	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right

	var x_spawn: float = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn: float = randf_range(spawn_pos1.y, spawn_pos2.y)

	return Vector2(x_spawn, y_spawn)