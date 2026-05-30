extends Area3D

@export var GoTo: PackedScene = null

func _on_body_entered(Body: Node3D) -> void:
	if (Body.is_in_group("Player")):
		Body.ChangeLevel(GoTo)
