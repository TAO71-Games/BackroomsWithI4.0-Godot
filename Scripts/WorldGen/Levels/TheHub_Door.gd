extends Node3D

const LEVEL_MULTIPLIER: int = 4
const LEVEL_SPAWN_OFFSET: Vector3 = Vector3(0, -1.075, 0.215)
var BASE_CHUNK: WorldGen_Chunk = null
var INIT_ROTATION: Vector3 = Vector3.ZERO

@export_category("Level")
@export var SpawnOnLevel: Dictionary[int, PackedScene] = {}
@export var LevelFoundObjs: Array[Node3D] = []
@export var LevelNotFoundObjs: Array[Node3D] = []

@export_category("Level keys")
@export var RequiresLevelKey: Dictionary[int, bool] = {}
@export var DefaultRequiresLevelKey: bool = true

@export_category("Door rotation")
@export var RotationObj: Node3D = null

@export_category("Other")
@export var Texts: Array[Label3D] = []
@export var Offset: int = 0
var Open: bool = false
var Locked: bool = false
var Level: int = 0

func _ready() -> void:
	INIT_ROTATION = RotationObj.rotation

func _process(Delta: float) -> void:
	if (BASE_CHUNK == null || BASE_CHUNK.BASE_WORLD_GENERATOR == null):
		await get_tree().process_frame
		return
	
	RotationObj.rotation.y = 90 if (Open) else 0  # TODO: Smooth rotation

func Init() -> void:
	Level = -BASE_CHUNK.Coords.x * LEVEL_MULTIPLIER + Offset
	Locked = (RequiresLevelKey[Level] if (Level in RequiresLevelKey) else DefaultRequiresLevelKey) && Level not in MultiplayerConnection.VisitedLevels
	
	for text in Texts:
		text.text = "Level " + str(Level)
	
	if (Level in SpawnOnLevel):
		var levelChunk: Node3D = SpawnOnLevel[Level].instantiate()
		BASE_CHUNK.BASE_WORLD_GENERATOR.add_child(levelChunk)
		
		levelChunk.global_position = global_position + LEVEL_SPAWN_OFFSET
		
		if ("Init" in levelChunk && "SetSeed" in levelChunk):
			levelChunk.SetSeed(randi())
			levelChunk.Init()
		
		for obj in LevelFoundObjs:
			obj.process_mode = Node.PROCESS_MODE_INHERIT
			obj.show()
		
		for obj in LevelNotFoundObjs:
			obj.process_mode = Node.PROCESS_MODE_DISABLED
			obj.hide()
	else:
		for obj in LevelNotFoundObjs:
			obj.process_mode = Node.PROCESS_MODE_INHERIT
			obj.show()
		
		for obj in LevelFoundObjs:
			obj.process_mode = Node.PROCESS_MODE_DISABLED
			obj.hide()

func Interact() -> void:
	if (Locked):
		var keyFound = BASE_CHUNK.BASE_WORLD_GENERATOR.Player.Inv_FindFirstItemWithTag("level_key")
		
		if (keyFound == null):
			return
		else:
			BASE_CHUNK.BASE_WORLD_GENERATOR.Player.Inv_UseItem(keyFound)
			Locked = false
	
	Open = !Open
	print("Open door")
