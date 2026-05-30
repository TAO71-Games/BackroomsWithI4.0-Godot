extends Node

@export var SidePanelGUI: Control = null
@export var OptionsGUI: Control = null
@export var CreditsGUI: Control = null
var CurrentConfigMode: String = ""

func ToggleConfigWindow(Win: String) -> void:
	SidePanelGUI.hide()
	SidePanelGUI.process_mode = Node.PROCESS_MODE_DISABLED
	
	OptionsGUI.hide()
	OptionsGUI.process_mode = Node.PROCESS_MODE_DISABLED
	
	CreditsGUI.hide()
	CreditsGUI.process_mode = Node.PROCESS_MODE_DISABLED
	
	if (Win == CurrentConfigMode):
		CurrentConfigMode = ""
	else:
		CurrentConfigMode = Win
	
	if (CurrentConfigMode == "options"):
		OptionsGUI.show()
		OptionsGUI.process_mode = Node.PROCESS_MODE_INHERIT
	elif (CurrentConfigMode == "credits"):
		CreditsGUI.show()
		CreditsGUI.process_mode = Node.PROCESS_MODE_INHERIT
	
	if (OptionsGUI.visible || CreditsGUI.visible):
		SidePanelGUI.show()
		SidePanelGUI.process_mode = Node.PROCESS_MODE_INHERIT

func StartGame() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level TheHub.tscn")
