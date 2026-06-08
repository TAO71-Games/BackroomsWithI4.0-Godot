class_name I4CharController extends Node

enum I4EyesSkinMode
{
	CURRENT = -1,
	HAPPY = 0,
	SAD = 1,
	ANGRY = 2,
	LOVE = 3
}

enum I4EyesControlMode
{
	CURRENT = -1,
	FOLLOW_PLAYER = 0,
	CUSTOM = 1
}

const I4_TOOLS: Array[Dictionary] = [
	{
		"name": "set_pose",
		"description": "Changes your pose",
		"parameters": {
			"type": "object",
			"properties": {
				"pose_name": {
					"type": "string",
					"description": "Pose name",
					"enum": ["default"]
				}
			},
			"required": ["pose_name"]
		}
	},
	{
		"name": "set_eyes",
		"description": "Changes your eyes",
		"parameters": {
			"type": "object",
			"properties": {
				"control_mode": {
					"type": "string",
					"description": "Eyes control mode",
					"enum": ["follow_player", "custom"]
				},
				"emotion": {
					"type": "string",
					"description": "Eyes emotion",
					"enum": ["happy", "sad", "angry", "love"]
				},
				"is_surprised": {
					"type": ["boolean", "null"],
					"description": "Wether you are surprised or not, this toggle makes your eyes smaller, null is 'keep unchanged'",
					"default": null
				},
				"move_vertical_l": {
					"type": ["float", "null"],
					"description": "Left eye vertical position, -1 is fully up, 0 is centered, 1 is fully down, null is 'keep unchanged', only works with the 'custom' control_mode",
					"default": null
				},
				"move_horizontal_l": {
					"type": ["float", "null"],
					"description": "Left eye horizontal position, -1 is fully right, 0 is centered, 1 is fully left, null is 'keep unchanged', only works with the 'custom' control_mode",
					"default": null
				},
				"move_vertical_r": {
					"type": ["float", "null"],
					"description": "Right eye vertical position, -1 is fully up, 0 is centered, 1 is fully down, null is 'keep unchanged', only works with the 'custom' control_mode",
					"default": null
				},
				"move_horizontal_r": {
					"type": ["float", "null"],
					"description": "Right eye horizontal position, -1 is fully right, 0 is centered, 1 is fully left, null is 'keep unchanged', only works with the 'custom' control_mode",
					"default": null
				}
			},
			"required": ["control_mode", "emotion"]
		}
	}
]

@export var I4Animator: AnimationPlayer = null
@export var I4Eyes: MeshInstance3D = null
var CurrentPose: StringName = "none"

func SetPose(Name: StringName = "none") -> void:
	pass

func SetEyes(
	ControlMode: I4EyesControlMode = I4EyesControlMode.CURRENT,
	SkinMode: I4EyesSkinMode = I4EyesSkinMode.CURRENT,
	IsSurprised: int = -1,
	CUSTOM_L_Vertical: float = -2,
	CUSTOM_L_Horizontal: float = -2,
	CUSTOM_R_Vertical: float = -2,
	CUSTOM_R_Horizontal: float = -2
) -> void:
	var eyesHappy = I4Eyes.find_blend_shape_by_name("Eyes_Happy")
	var eyesSad = I4Eyes.find_blend_shape_by_name("Eyes_Sad")
	var eyesAngry = I4Eyes.find_blend_shape_by_name("Eyes_Angry")
	var eyesLove = I4Eyes.find_blend_shape_by_name("Eyes_Love")
	var eyesSurprised = I4Eyes.find_blend_shape_by_name("Eye_?")
	var eyeLVertical = I4Eyes.find_blend_shape_by_name("Eye_Down_L")
	var eyeLHorizontal = I4Eyes.find_blend_shape_by_name("Eye_Right_L")
	var eyeRVertical = I4Eyes.find_blend_shape_by_name("Eye_Down_R")
	var eyeRHorizontal = I4Eyes.find_blend_shape_by_name("Eye_Right_R")
	
	if (ControlMode == I4EyesControlMode.FOLLOW_PLAYER):
		pass  # TODO: Follow player with its eyes
	elif (ControlMode == I4EyesControlMode.CUSTOM):
		if (CUSTOM_L_Vertical != -2):
			I4Eyes.set_blend_shape_value(eyeLVertical, clampf(CUSTOM_L_Vertical, -1, 1))
		
		if (CUSTOM_L_Horizontal != -2):
			I4Eyes.set_blend_shape_value(eyeLHorizontal, clampf(CUSTOM_L_Horizontal, -1, 1))
		
		if (CUSTOM_R_Vertical != -2):
			I4Eyes.set_blend_shape_value(eyeRVertical, clampf(CUSTOM_R_Vertical, -1, 1))
		
		if (CUSTOM_R_Horizontal != -2):
			I4Eyes.set_blend_shape_value(eyeRHorizontal, clampf(CUSTOM_R_Horizontal, -1, 1))
	
	if (SkinMode != I4EyesSkinMode.CURRENT):
		I4Eyes.set_blend_shape_value(eyesHappy, 1)
		I4Eyes.set_blend_shape_value(eyesAngry, 0)
		I4Eyes.set_blend_shape_value(eyesSad, 0)
		I4Eyes.set_blend_shape_value(eyesLove, 0)
		
		if (SkinMode == I4EyesSkinMode.HAPPY):
			I4Eyes.set_blend_shape_value(eyesHappy, 0)
		elif (SkinMode == I4EyesSkinMode.ANGRY):
			I4Eyes.set_blend_shape_value(eyesAngry, 1)
		elif (SkinMode == I4EyesSkinMode.SAD):
			I4Eyes.set_blend_shape_value(eyesSad, 1)
		elif (SkinMode == I4EyesSkinMode.LOVE):
			I4Eyes.set_blend_shape_value(eyesLove, 1)
		else:
			push_error("Unrecognized I4.0 eyes skin mode. Ignoring.")
	
	if (IsSurprised != 0):
		I4Eyes.set_blend_shape_value(eyesSurprised, clampi(IsSurprised, 0, 1))
