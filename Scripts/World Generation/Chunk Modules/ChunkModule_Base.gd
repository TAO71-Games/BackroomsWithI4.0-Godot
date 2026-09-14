class_name ChunkModule_Base extends Node

# Ignore this code; it is only used as a base for module creation

func _Run() -> void:
	pass

func _UpdateParameters() -> void:
	pass

func GetChunk() -> LevelChunk:
	return Utilities.GetParentUntilType(LevelChunk, self, get_tree().root)

func GetLevelGenerator() -> LevelGeneration:
	return GetChunk().get_parent()
