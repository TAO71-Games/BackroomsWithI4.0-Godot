class_name EntityAI extends CharacterBody3D

@export var Agent: NavigationAgent3D = null
var Speed: float = 5
var __target__: Node3D = null

func _ready() -> void:
	Agent.target_reached.connect(__on_target_reached__)
	await get_tree().physics_frame

func SetTarget(Target: Node3D) -> void:
	__target__ = Target

func _physics_process(_Delta: float) -> void:
	if (__target__ != null):
		Agent.set_target_position(__target__.global_position)
		
		var destination = Agent.get_next_path_position()
		var direction = global_position.direction_to(destination)
		
		print(destination)
		
		velocity = direction * Speed
		move_and_slide()

func __on_target_reached__() -> void:
	print("Target reached.")
