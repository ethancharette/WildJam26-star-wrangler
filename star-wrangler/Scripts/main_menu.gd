extends Control
class_name MainMenu

func Start_Game() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")

func Quit_Game() -> void:
	get_tree().quit()
