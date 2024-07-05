extends CharacterBody2D
class_name player
# TODO: clean up and inherit from a base 'character' class

@export var move_speed: float = 75.0 # common
@export var hp: int = 80 # common
var max_hp: int = 80

var time: float = 0

# Experience
var experience: int = 0
var exp_level: int = 1
var collected_exp: int = 0

# Attacks
var ice_spear: PackedScene = preload ("res://Scenes/Player/ice_spear.tscn")
var tornado: PackedScene = preload ("res://Scenes/Player/tornado.tscn")
var javelin: PackedScene = preload ("res://Scenes/Player/javelin.tscn")

# Attack Nodes
@onready var ice_spear_timer: Timer = get_node("Attack/IceSpearTimer")
@onready var ice_spear_atk_timer: Timer = get_node("Attack/IceSpearTimer/IceSpearAttackTimer")
@onready var tornado_timer: Timer = get_node("Attack/TornadoTimer")
@onready var tornado_atk_timer: Timer = get_node("Attack/TornadoTimer/TornadoAttackTimer")
@onready var javelin_base: Node2D = get_node("Attack/JavelinBase")

# IceSpear
var ice_spear_ammo: int = 0
var ice_spear_base_ammo: int = 0
@export var ice_spear_lvl: int = 0
var ice_spear_atk_spd: float = 1.5

# Tornado
var last_movement: Vector2 = Vector2.UP
var tornado_ammo: int = 0
var tornado_base_ammo: int = 0
@export var tornado_lvl: int = 0
var tornado_atk_spd: float = 3.0

# Javelin
var javelin_ammo: int = 0
@export var javelin_lvl: int = 0

# Enemy Related
var enemy_close: Array[Node2D] = []

# Upgrades
var collected_upgrades: Array[String] = []
var upgrade_options: Array[String] = []
var armor: int = 0
var speed: int = 0
var spell_cooldown: float = 0
var spell_size: float = 0
var additional_attacks: int = 0

@onready var sprite_node: Sprite2D = $Sprite2D # common
@onready var walk_timer_node: Timer = get_node("WalkTimer")
@onready var exp_bar_node: TextureProgressBar = get_node("GUILayer/GUI/ExperienceBar")
@onready var level_label_node: Label = get_node("GUILayer/GUI/ExperienceBar/HBoxContainer/LevelValue")
@onready var on_level_panel_node: Panel = get_node("GUILayer/GUI/LevelUp")
@onready var upgrade_options_node: VBoxContainer = get_node("GUILayer/GUI/LevelUp/UpgradeOptions")
@onready var level_up_stream_node: AudioStreamPlayer = get_node("GUILayer/GUI/LevelUp/snd_lvl_up")
@onready var health_bar_node: TextureProgressBar = get_node("GUILayer/GUI/HealthBar")
@onready var label_timer_node: Label = get_node("GUILayer/GUI/lbl_Timer")
@onready var collected_weapons_node: GridContainer = get_node("GUILayer/GUI/CollectedWeapons")
@onready var collected_upgrade_node: GridContainer = get_node("GUILayer/GUI/CollectedUpgrades")

@onready var item_option_scene: PackedScene = preload ("res://Scenes/General/item_option.tscn")
@onready var item_container_scene: PackedScene = preload ("res://Scenes/Player/GUI/item_container.tscn")

func _ready() -> void:
	max_hp = hp
	upgrade_character("icespear1")
	# attack()
	# TODO: Remove when script complete for mvp
	set_exp_bar(experience, calculate_experience_cap())
	_on_hurtbox_hurt(0, Vector2.ZERO, 0)
	level_label_node.text = str(exp_level)
	printerr("Script not complete: " + name)

func _physics_process(_delta: float) -> void:
	movement()

func movement() -> void:
	# TODO: Update to implement globals for inputs
	var x_move_input: float = Input.get_action_strength("MoveRight") - Input.get_action_strength("MoveLeft")
	var y_move_input: float = Input.get_action_strength("MoveDown") - Input.get_action_strength("MoveUp")
	var move_input: Vector2 = Vector2(x_move_input, y_move_input)
	if move_input != Vector2.ZERO:
		last_movement = move_input
		animate_sprite()

	flip_sprite(move_input.x)

	velocity = move_input.normalized() * move_speed
	move_and_slide()

func flip_sprite(move_x_result: float) -> void: # common
	if move_x_result > 0:
		sprite_node.flip_h = true
	elif move_x_result < 0:
		sprite_node.flip_h = false

func animate_sprite() -> void:
	if walk_timer_node.is_stopped():
		if sprite_node.frame >= sprite_node.hframes - 1:
			sprite_node.frame = 0
		else:
			sprite_node.frame += 1
		walk_timer_node.start()

func attack() -> void:
	if ice_spear_lvl > 0:
		ice_spear_timer.wait_time = ice_spear_atk_spd * (1 - spell_cooldown)
		if ice_spear_timer.is_stopped():
			ice_spear_timer.start()

	if tornado_lvl > 0:
		tornado_timer.wait_time = tornado_atk_spd * (1 - spell_cooldown)
		if tornado_timer.is_stopped():
			tornado_timer.start()

	if javelin_lvl > 0:
		spawn_javelin()

func get_random_target() -> Vector2:
	if not enemy_close.is_empty():
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP

func spawn_javelin() -> void:
	var get_jav_total: int = javelin_base.get_child_count()
	var calc_spawns: int = (javelin_ammo + additional_attacks) - get_jav_total
	while calc_spawns > 0:
		var new_javelin_node: Javelin = javelin.instantiate()
		new_javelin_node.global_position = global_position
		javelin_base.add_child(new_javelin_node)
		calc_spawns -= 1
	# update javelin
	var existing_javelins: Array = javelin_base.get_children()
	for i: Javelin in existing_javelins:
		i.update_javelin()

func calculate_experience(gem_experience: int) -> void:
	var experience_required: int = calculate_experience_cap()
	collected_exp += gem_experience
	if experience + collected_exp >= experience_required:
		collected_exp -= (experience_required - experience)
		exp_level += 1
		experience = 0
		experience_required = calculate_experience_cap()
		level_up()
	else:
		experience += collected_exp
		collected_exp = 0
	
	# print("exp: " + str(experience) + " || exp_req: " + str(experience_required))
	set_exp_bar(experience, experience_required)

func calculate_experience_cap() -> int:
	var exp_cap: int = exp_level
	if exp_cap < 20:
		exp_cap = exp_level * 5
	elif exp_cap < 40:
		exp_cap = exp_level * 8
	else:
		exp_cap = exp_level * 12

	return exp_cap

func set_exp_bar(set_value: int=1, set_max_value: int=100) -> void:
	exp_bar_node.value = set_value
	exp_bar_node.max_value = set_max_value
	
func level_up() -> void:
	level_up_stream_node.play()
	level_label_node.text = str(exp_level)
	var tween: Tween = on_level_panel_node.create_tween()
	tween.tween_property(on_level_panel_node, "position", Vector2(220, 50), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	on_level_panel_node.visible = true
	var options: int = 0
	var options_max: int = 3
	while options < options_max:
		var item_option_node: ItemOption = item_option_scene.instantiate()
		item_option_node.item = get_random_item()
		upgrade_options_node.add_child(item_option_node)
		options += 1

	get_tree().paused = true

func upgrade_character(upgrade: String) -> void:
	match upgrade:
		"icespear1":
			ice_spear_lvl = 1
			ice_spear_base_ammo += 1
		"icespear2":
			ice_spear_lvl = 2
			ice_spear_base_ammo += 1
		"icespear3":
			ice_spear_lvl = 3
		"icespear4":
			ice_spear_lvl = 4
			ice_spear_base_ammo += 2
		"tornado1":
			tornado_lvl = 1
			tornado_base_ammo += 1
		"tornado2":
			tornado_lvl = 2
			tornado_base_ammo += 1
		"tornado3":
			tornado_lvl = 3
			tornado_atk_spd -= 0.5
		"tornado4":
			tornado_lvl = 4
			tornado_base_ammo += 1
		"javelin1":
			javelin_lvl = 1
			javelin_ammo = 1
		"javelin2":
			javelin_lvl = 2
		"javelin3":
			javelin_lvl = 3
		"javelin4":
			javelin_lvl = 4
		"armor1", "armor2", "armor3", "armor4":
			armor += 1
		"speed1", "speed2", "speed3", "speed4":
			move_speed += 20.0
		"tome1", "tome2", "tome3", "tome4":
			spell_size += 0.10
		"scroll1", "scroll2", "scroll3", "scroll4":
			spell_cooldown += 0.05
		"ring1", "ring2":
			additional_attacks += 1
		"food":
			hp += 20
			hp = clamp(hp, 0, max_hp)
	adjust_gui_collection(upgrade)
	attack()

	var option_children: Array = upgrade_options_node.get_children()
	for i: ItemOption in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	on_level_panel_node.visible = false
	on_level_panel_node.position = Vector2(800, 50)
	get_tree().paused = false
	calculate_experience(0)

func get_random_item() -> String:
	var db_list: Array[String] = []
	for upgrade: String in UpgradeDB.UPGRADES.keys():
		if upgrade in collected_upgrades:
			pass
		elif upgrade in upgrade_options:
			pass
		elif UpgradeDB.UPGRADES[upgrade]["type"] == "item":
			pass
		elif UpgradeDB.UPGRADES[upgrade]["prerequisite"].size() > 0:
			for pr: String in UpgradeDB.UPGRADES[upgrade]["prerequisite"]:
				if pr not in collected_upgrades:
					pass
				else:
					db_list.append(upgrade)
		else:
			db_list.append(upgrade)

	if db_list.size() > 0:
		var random_item: String = db_list.pick_random()
		upgrade_options.append(random_item)
		return random_item
	else:
		return "food"

func change_time(arg_time: int=0) -> void:
	time = arg_time
	var minutes_val: int = int(time / 60)
	var seconds_val: int = int(time) % 60
	var minute_str: String = str(minutes_val)
	var seconds_str: String = str(seconds_val)
	if minutes_val < 10:
		minute_str = str(0, minutes_val)
	if seconds_val < 10:
		seconds_str = str(0, seconds_val)

	label_timer_node.text = str(minute_str, ":", seconds_str)

func adjust_gui_collection(upgrade: String) -> void:
	var get_upgrade_display_name: String = UpgradeDB.UPGRADES[upgrade]["display_name"]
	var get_type: String = UpgradeDb.UPGRADES[upgrade]["type"]
	var item_container_node: ItemContainer
	if get_type != "food":
		var get_collected_display_names: Array = []
		for i: String in collected_upgrades:
			get_collected_display_names.append(UpgradeDB.UPGRADES[i]["display_name"])
		if not get_upgrade_display_name in get_collected_display_names:
			item_container_node = item_container_scene.instantiate()
			item_container_node.upgrade = upgrade

			match get_type:
				"weapon":
					collected_weapons_node.add_child(item_container_node)
				"upgrade":
					collected_upgrade_node.add_child(item_container_node)
				_:
					printerr("Error in inserting new item container")

func _on_hurtbox_hurt(damage: int, _angle: Vector2, _knockback_amount: int) -> void: # common-ish
	hp -= clamp(damage - armor, 1, 9999)
	health_bar_node.max_value = max_hp
	health_bar_node.value = hp

func _on_ice_spear_timer_timeout() -> void:
	ice_spear_ammo += ice_spear_base_ammo + additional_attacks
	ice_spear_atk_timer.start()

func _on_ice_spear_attack_timer_timeout() -> void:
	if ice_spear_ammo > 0:
		var ice_spear_node: IceSpear = ice_spear.instantiate()
		ice_spear_node.position = position
		ice_spear_node.target = get_random_target()
		ice_spear_node.level = ice_spear_lvl
		add_child(ice_spear_node)
		ice_spear_ammo -= 1
		if ice_spear_ammo > 0:
			ice_spear_atk_timer.start()
		else:
			ice_spear_atk_timer.stop()

func _on_tornado_timer_timeout() -> void:
	tornado_ammo += tornado_base_ammo + additional_attacks
	tornado_atk_timer.start()

func _on_tornado_attack_timer_timeout() -> void:
	if tornado_ammo > 0:
		var tornado_node: Tornado = tornado.instantiate()
		tornado_node.position = position
		tornado_node.last_movement = last_movement
		tornado_node.level = tornado_lvl
		add_child(tornado_node)
		tornado_ammo -= 1
		if tornado_ammo > 0:
			tornado_atk_timer.start()
		else:
			tornado_atk_timer.stop()

func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if enemy_close.has(body):
		enemy_close.erase(body)

func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp: int = area.collect()
		calculate_experience(gem_exp)
