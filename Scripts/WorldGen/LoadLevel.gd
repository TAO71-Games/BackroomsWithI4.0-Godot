extends Node

func _ready() -> void:
	if (Globals.LevelToLoad == null):
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	else:
		get_tree().change_scene_to_packed(Globals.LevelToLoad)
