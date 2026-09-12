extends Node

@export_category("Global GUI elements")
@export var GUI_Elements: Dictionary[StringName, Control] = {
	"ViewDistance": null,
	"ShadowViewDistance": null,
	"Sensibility": null,
	"GenerationTime": null,
	"CameraQualityLevel": null,
	"CameraSaveCompressionLevel": null,
	"Multiplayer_Host": null,
	"Multiplayer_Port": null,
	"Multiplayer_UpdateTime": null,
	"User_Username": null,
	"User_Password": null,
	"Sound_Master": null,
	"Sound_Entity": null,
	"Sound_Music": null,
	"Sound_SFX": null,
	"Sound_Player_Voice": null,
	"Sound_Player_SFX": null,
}

@export_category("Sound players element")
@export var GUI_Sound_Players_Container: Control = null
@export var GUI_Sound_Players_Template: Control = null
const GUI_Sound_Players_PlayerName: String = "PlayerName"
const GUI_Sound_Players_VoiceSliderPath: String = "Volumes.Voice.Slider.HSlider"
const GUI_Sound_Players_SFXSliderPath: String = "Volumes.SFX.Slider.HSlider"
const GUI_Sound_Players_DeleteBTNPath: String = "Delete"

func __parse_control_element_path__(Cont: Control, ElementPath: String) -> Control:
	var currentObj = Cont
	
	for objName in ElementPath.split("."):
		if (objName.length() == 0):
			continue
		
		for obj in currentObj.get_children(false):
			if (obj.name == objName):
				currentObj = obj
				break
	
	return currentObj

func __new_sound_players_element__() -> void:
	Globals.Instance.Sound_Players["NAME HERE"] = {"voice": 0, "sfx": 0}
	Load()

func Load() -> void:
	for p in GUI_Elements.keys():
		if (p not in Globals.Instance):
			continue
		
		if ("item_selected" in GUI_Elements[p]):
			GUI_Elements[p].select(Globals.Instance.get(p))
		elif ("value" in GUI_Elements[p]):
			GUI_Elements[p].set("value", Globals.Instance.get(p))
		elif ("text" in GUI_Elements[p]):
			GUI_Elements[p].set("text", Globals.Instance.get(p))
	
	for child in GUI_Sound_Players_Container.get_children(false):
		child.queue_free()
	
	for pn in Globals.Instance.Sound_Players.keys():
		var child: Control = GUI_Sound_Players_Template.duplicate()
		child.visible = true
		GUI_Sound_Players_Container.add_child(child)
		
		var playerNameText: TextEdit = __parse_control_element_path__(child, GUI_Sound_Players_PlayerName)
		var voiceSlider: Slider = __parse_control_element_path__(child, GUI_Sound_Players_VoiceSliderPath)
		var sfxSlider: Slider = __parse_control_element_path__(child, GUI_Sound_Players_SFXSliderPath)
		var deleteBtn: Button = __parse_control_element_path__(child, GUI_Sound_Players_DeleteBTNPath)
		
		playerNameText.text = pn
		voiceSlider.value = Globals.Instance.Sound_Players[pn].get("voice", 0)
		sfxSlider.value = Globals.Instance.Sound_Players[pn].get("sfx", 0)
		deleteBtn.pressed.connect(func():
			Globals.Instance.Sound_Players.erase(pn)
			child.queue_free()
		)

func Save() -> void:
	for p in GUI_Elements.keys():
		var v = null
		
		if ("item_selected" in GUI_Elements[p]):
			v = GUI_Elements[p].selected
		elif ("value" in GUI_Elements[p]):
			v = GUI_Elements[p].value
		elif ("text" in GUI_Elements[p]):
			v = GUI_Elements[p].text
		else:
			push_error("Invalid config parameter type. Ignoring.")
			continue
		
		Globals.Instance.set(p, v)
	
	Globals.Instance.Sound_Players = {}
	
	for child in GUI_Sound_Players_Container.get_children(false):
		var playerName = __parse_control_element_path__(child, GUI_Sound_Players_PlayerName).text
		var voice = __parse_control_element_path__(child, GUI_Sound_Players_VoiceSliderPath).value
		var sfx = __parse_control_element_path__(child, GUI_Sound_Players_SFXSliderPath).value
		
		Globals.Instance.Sound_Players[playerName] = {"voice": voice, "sfx": sfx}
	
	Globals.Instance.SaveConfig()

func _ready() -> void:
	Globals.CheckInstance()
	Load()
