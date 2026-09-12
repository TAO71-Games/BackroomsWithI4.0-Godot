class_name WorldGen_Chunk_SideObject extends Node

enum WorldGen_Chunk_Side
{
	LEFT = 0,
	RIGHT = 1,
	FRONT = 2,
	BACK = 3
}

var BASE_CHUNK: WorldGen_Chunk = null
@export var ChunkSide: WorldGen_Chunk_Side = WorldGen_Chunk_Side.LEFT
@export var ChunkIndex: int = 0
@export var ObjectsToActivate: Array[Node] = []
@export var ObjectsToDeactivate: Array[Node] = []
@export var DeleteDeactivated: bool = true

func Init() -> void:
	var activate = (
		(ChunkSide == WorldGen_Chunk_Side.LEFT && ChunkIndex == BASE_CHUNK.Chunk_Left) ||
		(ChunkSide == WorldGen_Chunk_Side.RIGHT && ChunkIndex == BASE_CHUNK.Chunk_Right) ||
		(ChunkSide == WorldGen_Chunk_Side.FRONT && ChunkIndex == BASE_CHUNK.Chunk_Front) ||
		(ChunkSide == WorldGen_Chunk_Side.BACK && ChunkIndex == BASE_CHUNK.Chunk_Back)
	)
	
	var deactivatedObjs = []
	
	for obj in ObjectsToActivate:
		if (activate):
			obj.process_mode = Node.PROCESS_MODE_INHERIT
			obj.show()
			
			if (obj in deactivatedObjs):
				deactivatedObjs.erase(obj)
		else:
			obj.process_mode = Node.PROCESS_MODE_DISABLED
			obj.hide()
			
			if (obj not in deactivatedObjs):
				deactivatedObjs.append(obj)
	
	for obj in ObjectsToDeactivate:
		if (activate):
			obj.process_mode = Node.PROCESS_MODE_DISABLED
			obj.hide()
			
			if (obj not in deactivatedObjs):
				deactivatedObjs.append(obj)
		else:
			obj.process_mode = Node.PROCESS_MODE_INHERIT
			obj.show()
			
			if (obj in deactivatedObjs):
				deactivatedObjs.erase(obj)
	
	for obj in deactivatedObjs:
		obj.queue_free()
