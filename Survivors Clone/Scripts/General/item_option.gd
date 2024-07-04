extends ColorRect
class_name ItemOption

var mouse_over: bool = false
var item: String = ""

@onready var player_node: player = get_tree().get_first_node_in_group("player")
@onready var name_label: Label = $lbl_Name
@onready var desc_label: Label = $lbl_Description
@onready var level_label: Label = $lbl_Level
@onready var item_icon: TextureRect = get_node("ColorRect/TextureRect")

signal selected_upgrade(upgrade: String)

func _ready() -> void:
	connect("selected_upgrade", Callable(player_node, "upgrade_character"))
	if item == "":
		item = "food"
	name_label.text = UpgradeDB.UPGRADES[item]["display_name"]
	desc_label.text = UpgradeDB.UPGRADES[item]["details"]
	level_label.text = UpgradeDB.UPGRADES[item]["level"]
	item_icon.texture = load(UpgradeDB.UPGRADES[item]["icon"])

func _input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		if mouse_over:
			emit_signal("selected_upgrade", item)

func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false
