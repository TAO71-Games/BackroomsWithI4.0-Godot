extends EntityAI

@export var Player: CharacterMovement = null

func _ready() -> void:
	SetTarget(Player)
