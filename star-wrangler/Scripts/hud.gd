extends Control

@export var bounty_image : TextureRect
@export var game_over_panel : Panel

func _ready() -> void:
	game_over_panel.visible = false

func _update_bounty_image(c : Constellation) -> void:
	bounty_image.texture = c.shaded_sprite.texture


func _on_bounty_changed(constellation: Constellation) -> void:
	_update_bounty_image(constellation)


func _on_all_bounties_collected() -> void:
	game_over_panel.visible = true


func _back_to_menu() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
