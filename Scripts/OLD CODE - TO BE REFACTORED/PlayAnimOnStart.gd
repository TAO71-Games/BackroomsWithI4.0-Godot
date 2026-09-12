extends AnimationPlayer

@export var AnimationName: StringName = ""
@export var Speed: float = 1
@export var FromEnd: bool = false

func _ready() -> void:
	play(AnimationName, -1, Speed, FromEnd)
