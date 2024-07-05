extends Control

var level: String = "res://Scenes/Levels/World/world.tscn"

func _on_btn_play_click_end() -> void:
	get_tree().change_scene_to_file(level)

func _on_btn_exit_click_end() -> void:
	get_tree().quit()
