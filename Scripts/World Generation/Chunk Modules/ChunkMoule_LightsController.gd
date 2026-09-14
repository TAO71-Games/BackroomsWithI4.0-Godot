class_name ChunkModule_LightController extends ChunkModule_Base

# NOTE: This script is expected to be a child of a chunk

## Light objects to ignore
@export var IgnoreLights: Array[Light3D] = []

func _Run() -> void:
	# Get the level generator
	var levelGen = Utilities.GetParentUntilType(LevelGeneration, get_parent(), get_tree().root)
	
	# Get all the lights in the chunk
	var lights = Utilities.GetAllChildrenOfType(Light3D, Utilities.GetParentUntilType(LevelChunk, get_parent(), get_tree().root))
	
	# For each light
	for light in lights:
		# Check if the game is running in a server
		if (Utilities.IsServer()):
			# It is a server. Delete the light (since the server can't see the map and doesn't need lights)
			light.queue_free()
			continue
		
		# Check if the light is in the ignore list
		if (light in IgnoreLights):
			# It is. Skip this light
			continue
		
		# Set the distance fade
		light.distance_fade_enabled = true
		light.distance_fade_begin = Utilities.GetInstance().Generation_Radius + (levelGen.GeneralChunkSize.x * levelGen.GeneralChunkSize.z) - 10
		light.distance_fade_shadow = light.distance_fade_begin
		light.distance_fade_length = 10
	
	# Clear the lights array
	lights.clear()
