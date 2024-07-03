extends ColorRect
class_name ItemOption

var mouse_over: bool = false
var item = null

@onready var player_node: player = get_tree().get_first_node_in_group("player")

signal selected_upgrade(upgrade)

func _ready() -> void:
	connect("selected_upgrade", Callable(player_node, "upgrade_character"))

func _input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		if mouse_over:
			emit_signal("selected_upgrade", item)

func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false
