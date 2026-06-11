class_name WorldGen_Chunk extends Node3D

var BASE_WORLD_GENERATOR: WorldGen = null

@export var ChunkScripts: Array[Node] = []
var Chunk_Front: int = -1
var Chunk_Back: int = -1
var Chunk_Left: int = -1
var Chunk_Right: int = -1

var RNG: RandomNumberGenerator = RandomNumberGenerator.new()
var IsPlayerSpawn: bool = false
var IsEntitySpawn: bool = false
var Coords: Vector3i = Vector3i.ZERO

func SetSeed(Seed: int) -> void:
	RNG.seed = Seed

func Init() -> void:
	for script in ChunkScripts:
		if (script.process_mode == Node.PROCESS_MODE_DISABLED):
			continue
		
		if ("BASE_CHUNK" in script):
			script.BASE_CHUNK = self
		
		if ("SetSeed" in script):
			script.SetSeed(RNG.randi())
		
		if ("Init" in script):
			script.Init()
	
	var lightFadeScale = 1
	
	if (BASE_WORLD_GENERATOR != null):
		lightFadeScale = (BASE_WORLD_GENERATOR.ChunkSize.x + BASE_WORLD_GENERATOR.ChunkSize.y + BASE_WORLD_GENERATOR.ChunkSize.z) / 3.0
	
	for child in Globals.GetAllChildren(self):
		if (child is Light3D):
			child.distance_fade_enabled = true
			child.distance_fade_begin = clampf(Globals.Instance.ViewDistance * lightFadeScale - lightFadeScale, 5, 200)
			child.distance_fade_length = lightFadeScale
			child.distance_fade_shadow = Globals.Instance.ShadowViewDistance
