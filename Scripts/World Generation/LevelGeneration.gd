class_name LevelGeneration extends Node

enum NoiseMapType
{
	## Creates a fully black noise map (only first chunk will be used)
	ALL_BLACK = 0,
	
	## Creates a fully white noise map (only last chunk will be used)
	ALL_WHITE = 1,
	
	## Creates a noise map using Perlin noise
	PERLIN_NOISE = 2
}

enum RandomizeMode
{
	## Uses `randi()` to randomize
	RANDOM = 0,
	
	## Uses `RandomNumberGenerator.randi()` to randomize
	RNG = 1,
	
	## Position-based (level generator) or index-based (chunk modules) [read the code for more details]
	INDEX = 2,
	# About INDEX:
	# For chunks, it uses `pos.y * pos.x + pos.y * pos.z + pos.x - pos.z + pos.y * 5`, where `pos` is the global position of the chunk
	# For chunk modules, it uses the module index in the list
	
	## Uses the parent's seed (will always be 0 for the level generator)
	PARENT = 3
}

var _GeneratedChunksContainer: Node
var _ChunkConstants: Node
var _Seed: int = 0
var _RNG: RandomNumberGenerator = RandomNumberGenerator.new()

@export_category("Generation")
## Radius where the chunks will be generated
var GenerationRadius: int = 20

## Avoids the chunks in this range
@export var AvoidChunks: Array[Vector3Range] = []  # TODO

@export_group("Noise maps")
## Noise map textures. The key is a comma-separated string of the floors where the noise map will be applied. The value is the noise map image.
## Example: `{"0,1,5": <image>}` will apply the noise map image for the floors 0, 1, and 5
@export var NoiseMaps: Dictionary[String, Texture2D] = {}

## Type of noise map to generate when a noise map image is not found for a floor
@export var DefaultNoiseMapType: NoiseMapType = NoiseMapType.PERLIN_NOISE

## Size of noise map image to generate when a noise map image is not found for a floor
@export var DefaultNoiseMapSize: Vector2i = Vector2i(1024, 1024)

@export_group("Floors")
## Maximum floors to generate.
## X = Number of floors to generate downward.
## Y = Number of floors to generate upward.
## Example: `(0, 0)` generates no floors
@export var MaxFloors: Vector2i = Vector2i(0, 0)

## Number of floors to preload.
## This takes up more RAM and compute power, but preloads the X and Y range of floors to avoid loading screens or small freezes.
## X = Number of floors to preload downward.
## Y = Number of floors to preload upward.
## Example: `(0, 0)` disables preloading
@export var PreloadFloors: Vector2i = Vector2i(0, 0)

@export_category("Chunks")
## Chunk size used for generation.
## All chunks MUST be this size
@export var GeneralChunkSize: Vector3i = Vector3i(20, 6, 20)

## Mode of randomizing for the chunks.
## For multiplayer or saved games, it is recommended to use either `RNG` or `INDEX`
@export var ChunkRandomizeMode: RandomizeMode = RandomizeMode.INDEX

static func CalculateSeedForObject(
	Mode: RandomizeMode,
	Obj: Node,
	RNG: RandomNumberGenerator = null,
	ModuleIdx: int = -1,
	Position: Vector3 = Vector3.ZERO
) -> int:
	# Check the randomize mode
	match Mode:
		RandomizeMode.RANDOM:
			# Totally random seed
			return randi()
		RandomizeMode.RNG:
			# Random seed based of the RandomNumberGenerator
			# Make sure the RandomNumberGenerator is not null
			if (RNG == null):
				# It is null; return 0
				return 0
			
			# Return a random number from the RandomNumberGenerator
			return RNG.randi()
		RandomizeMode.INDEX:
			# NOT random seed, based of the position (if it's a level generator) or the modules index (if it's a chunk generator module)
			# Check the object type
			if (Obj is LevelChunk):
				# The object is a chunk
				# Return a position-based seed
				return absi(int(Position.y * Position.x + Position.y * Position.z + Position.x - Position.z + Position.y * 5))
			elif (Obj is ChunkModuleBase):
				# The object is expected to be a chunk module
				# Return an index-based seed (module index)
				return ModuleIdx
			
			# Invalid object type, push error
			push_error("Invalid object type for index-based randomization.")
		RandomizeMode.PARENT:
			# NOT random seed, the same as the parent of the object
			# Check the object type
			if (Obj is LevelChunk):
				# The object is a chunk generator
				# Return the seed from the level generator
				return Obj.get_parent().get_parent()._Seed
			
			# The object type is NOT a chunk generator; try to get the seed from it's parent (return 0 if no seed is found in the parent)
			return Obj.get_parent()._Seed if ("_Seed" in Obj.get_parent()) else Obj.get_parent().Seed if ("Seed" in Obj.get_parent()) else 0
		_:
			push_error("Invalid randomize mode. 0 will be returned instead.")
	
	# Return 0 as a fallback
	return 0

func CreateFloorImage() -> Image:
	const FORMAT = Image.FORMAT_RGBA8
	var img
	
	# Check image type
	match DefaultNoiseMapType:
		NoiseMapType.ALL_BLACK:
			# Create black image
			img = Image.create(DefaultNoiseMapSize.x, DefaultNoiseMapSize.y, false, FORMAT)
			img.fill(Color.BLACK)
		NoiseMapType.ALL_WHITE:
			# Create white image
			img = Image.create(DefaultNoiseMapSize.x, DefaultNoiseMapSize.y, false, FORMAT)
			img.fill(Color.WHITE)
		NoiseMapType.PERLIN_NOISE:
			# Create an image with perlin noise
			var perlin = FastNoiseLite.new()
			perlin.noise_type = FastNoiseLite.TYPE_PERLIN
			
			img = perlin.get_image(DefaultNoiseMapSize.x, DefaultNoiseMapSize.y, false, false, true)
		_:
			# Invalid option; push error
			push_error("Invalid NoiseMapType. Image will not be generated (null will be returned instead).")
	
	# Return the image
	return img

func GetFloorTexture(Floor: int) -> Image:
	var img = null
	
	# For each key in the noise maps (example of a key: "0,1,5")
	for floorsUnparsed in NoiseMaps.keys():
		# Split the string and for each new string (example: "0")
		for floorIDX in floorsUnparsed.split(","):
			# Strip the edges of the string (example: " 0 " => "0")
			floorIDX = floorIDX.strip_edges(true, true)
			
			# Parse the string as an integer (example: "0" => 0)
			floorIDX = int(floorIDX)
			
			# Check if the desired floor is this one
			if (Floor == floorIDX):
				# It is! Set the image with the noise map and stop the loop
				img = NoiseMaps[floorsUnparsed].get_image()
				break
		
		# Stop the loop of the image is set (the desired floor was found)
		if (img != null):
			break
	
	# If the image is not set (the desired floor was not found), create an image
	if (img == null):
		img = CreateFloorImage()
	
	# Return the image
	return img

func GetChunkIndexFromFloorTexture(Floor: Image, ChunkPosXZ: Vector2i) -> int:
	# ChunkPosXZ must be the GLOBAL POSITION (x, z)
	# Get the texture size
	var texSize = Floor.get_size()
	
	# Calculate the pixel position in the image
	var pixelPos = Vector2i(
		ChunkPosXZ.x % texSize.x,
		ChunkPosXZ.y % texSize.y
	)
	
	# Make sure the pixel is inside the image
	while (pixelPos.x < 0): pixelPos.x += texSize.x
	while (pixelPos.y < 0): pixelPos.y += texSize.y
	while (pixelPos.x > texSize.x): pixelPos.x -= texSize.x
	while (pixelPos.y > texSize.y): pixelPos.y -= texSize.y
	
	# Get the G (RGBA) parameter from the pixel's color in the image, then multiply it by the size of the chunk constants, and round it
	# This returns the exact chunk index
	return roundi(int(Floor.get_pixel(pixelPos.x, pixelPos.y).g * (_ChunkConstants.get_children(false).size() - 1)))

func GenerateChunk(Position: Vector3i, ChunkIdx: int, NearbyChunks: PackedInt32Array) -> Node3D:
	# Position must be the CHUNK RELATIVE POSITION
	# Make sure the chunk index is valid
	if (ChunkIdx >= _ChunkConstants.get_children(false).size()):
		# Invalid chunk index, push error
		push_error("Could not generate chunk: invalid index. Null will be returned instead.")
		return null
	
	# The chunk index is valid, continue generation
	var generatedChunk: LevelChunk = _ChunkConstants.get_children(false)[ChunkIdx].duplicate()  # Duplicate the selected chunk. The chunk MUST be a LevelChunk or derivated
	_GeneratedChunksContainer.add_child(generatedChunk)  # Reparent the generated chunk to the generated chunks container
	generatedChunk.name = "%s %s %s" % [Position.x, Position.y, Position.z]
	generatedChunk.global_position = Position * GeneralChunkSize
	generatedChunk.visible = true
	generatedChunk.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Set chunk script parameters
	generatedChunk._Seed = CalculateSeedForObject(ChunkRandomizeMode, generatedChunk, _RNG, -1, generatedChunk.global_position)
	generatedChunk._NearbyChunkIdxs = NearbyChunks
	generatedChunk._UpdateParameters()
	generatedChunk._UpdateModulesParameters()
	generatedChunk._RunModules()
	
	# Return the generated chunk
	return generatedChunk

func GenerateNearbyChunks(PlayerPosition: Vector3) -> void:
	# NOTE: This function is VERY computational expensive, please avoid calling it a lot
	
	# PlayerPosition must be the GLOBAL POSITION
	# Get the chunk where the player is
	var playerChunk = GetPlayerCurrentChunk(PlayerPosition)
	
	# Specify the floors that will be generated
	var floorsToGenerate = [playerChunk.y]  # Default is just one floor
	
	# Add the floors downward (for floor preprocessing)
	if (PreloadFloors.x != 0):
		# For every floor downward
		for f in range(playerChunk.y - absi(PreloadFloors.x), playerChunk.y):
			# Ensure it's in the floors limit
			if (f < -absi(MaxFloors.x)):
				# It is not in the limit! Skip this floor
				continue
			
			# It is in the limit! Append this floor to the array
			floorsToGenerate.append(f)
	
	# Add the floors upward (for floor preprocessing)
	if (PreloadFloors.y != 0):
		# For every floor upward
		for f in range(playerChunk.y + 1, playerChunk.y + absi(PreloadFloors.y) + 1):
			# Ensure it's in the floors limit
			if (f > absi(MaxFloors.y)):
				# It is not in the limit! Skip this floor
				continue
			
			# It is in the limit! Append this floor to the array
			floorsToGenerate.append(f)
	
	# Ensure the floors to generate are in the floor limit
	for f in floorsToGenerate:
		floorsToGenerate[floorsToGenerate.find(f)] = clampi(f, -absi(MaxFloors.x), absi(MaxFloors.y))
	
	# Create an array for the generated floors
	var generatedFloors = []
	
	# For every floor (y)
	for y in floorsToGenerate:
		# Ensure this floors was NOT generated
		if (y in generatedFloors):
			# This floor has already been generated, ignore this floor
			continue
		
		# Get the image for the floor
		var floorImage = GetFloorTexture(y)
		
		# Create a dictionary with the chunks to generate
		var chunksToGenerate = {}
		
		# From -x to +x (relative to the player)
		@warning_ignore("integer_division")
		for x in range(-GenerationRadius / 2, GenerationRadius / 2 + 1):
			# From -z to +z (relative to the player)
			@warning_ignore("integer_division")
			for z in range(-GenerationRadius / 2, GenerationRadius / 2 + 1):
				# Convert chunk position to vector
				var chunkPos = Vector3i(x, y - playerChunk.y, z) + playerChunk
				
				# Skip this chunk if any of these conditions apply:
				# 1. The chunk is already generated
				# 2. The chunk is not in the render radius
				# 3. The chunk is in the range of any of the `AvoidChunks`
				if (
					_GeneratedChunksContainer.find_child("%s %s %s" % [chunkPos.x, chunkPos.y, chunkPos.z], false, false) != null ||
					!IsChunkInRenderRadius(chunkPos, playerChunk, false) ||
					Vector3Range.IsInRangeMultiple(AvoidChunks, chunkPos)
				):
					# The chunk has already been generated or it's not in the generation radius, ignore
					continue
				
				# Add to the chunks to generate dictionary the chunk position (key) and the chunk index (value)
				chunksToGenerate[chunkPos] = GetChunkIndexFromFloorTexture(floorImage, Vector2i(x, z))
		
		# For every chunk position in the dictionary of the chunks to generate
		for chunkPos in chunksToGenerate.keys():
			# Calculate nearby chunks and get their indexes
			var leftChunk = chunkPos - Vector3i(1, 0, 0)
			var rightChunk = chunkPos + Vector3i(1, 0, 0)
			var backChunk = chunkPos - Vector3i(0, 0, 1)
			var frontChunk = chunkPos + Vector3i(0, 0, 1)
			
			# If the nearby chunk is already in the dictionary of the chunks to generate, avoid recalculation
			leftChunk = chunksToGenerate.get(leftChunk, GetChunkIndexFromFloorTexture(floorImage, Vector2i(leftChunk.x, leftChunk.z)) if (Vector3Range.IsInRangeMultiple(AvoidChunks, leftChunk * GeneralChunkSize)) else -1)
			rightChunk = chunksToGenerate.get(rightChunk, GetChunkIndexFromFloorTexture(floorImage, Vector2i(rightChunk.x, rightChunk.z)) if (Vector3Range.IsInRangeMultiple(AvoidChunks, rightChunk * GeneralChunkSize)) else -1)
			backChunk = chunksToGenerate.get(backChunk, GetChunkIndexFromFloorTexture(floorImage, Vector2i(backChunk.x, backChunk.z)) if (Vector3Range.IsInRangeMultiple(AvoidChunks, backChunk * GeneralChunkSize)) else -1)
			frontChunk = chunksToGenerate.get(frontChunk, GetChunkIndexFromFloorTexture(floorImage, Vector2i(frontChunk.x, frontChunk.z)) if (Vector3Range.IsInRangeMultiple(AvoidChunks, frontChunk * GeneralChunkSize)) else -1)
			
			# Generate the chunk
			GenerateChunk(chunkPos, chunksToGenerate[chunkPos], [leftChunk, rightChunk, backChunk, frontChunk])
		
		# Clear the dictionary
		chunksToGenerate.clear()
		
		# Append this floor to the generated floors list
		generatedFloors.append(y)
	
	# Clear all of the arrays
	floorsToGenerate.clear()
	generatedFloors.clear()

func DeleteChunks(PlayerPositions: Array[Vector3i]) -> void:
	# NOTE: This function is VERY computational expensive, please avoid calling it a lot
	
	# PlayerPositions must have the GLOBAL POSITION of every player
	# For each generated chunk
	for chunk in _GeneratedChunksContainer.get_children(false):
		# Create new variable and set to to true by default. This variable controls wether the chunk should be deleted or not
		var delete = true
		
		# Get the chunk position
		var chunkPos = chunk.name.split(" ")
		chunkPos = Vector3i(int(chunkPos[0]), int(chunkPos[1]), int(chunkPos[2]))
		
		# For each player
		for playerRealPos in PlayerPositions:
			# Get the player chunk
			var playerChunk = GetPlayerCurrentChunk(playerRealPos)
			
			# Make sure the chunk distance is less or equals the generation radius and the chunk is in the same floor or in the preload range
			if (IsChunkInRenderRadius(chunkPos, playerChunk, true)):
				# The chunk is nearby a player (or preloaded); do not delete
				delete = false
				break
		
		# Delete the chunk if it should be deleted
		if (delete):
			chunk.queue_free()

func GetPlayerCurrentChunk(PlayerPosititon: Vector3) -> Vector3i:
	# PlayerPosition must be the GLOBAL POSITION
	return Vector3i(
		roundi(PlayerPosititon.x / GeneralChunkSize.x),
		floori(PlayerPosititon.y / GeneralChunkSize.y),
		roundi(PlayerPosititon.z / GeneralChunkSize.z),
	)

func IsChunkInRenderRadius(ChunkIdx: Vector3i, PlayerChunkIdx: Vector3i, IncludeFloors: bool) -> bool:
	# ChunkIdx must be the CHUNK RELATIVE POSITION of the chunk
	# PlayerChunkIdx must be the CHUNK RELATIVE POSITION where the player is
	@warning_ignore("integer_division")
	return (
		# Ensure the chunk relative position is in the generation radius (X and Z)
		absi(ChunkIdx.x - PlayerChunkIdx.x) <= GenerationRadius / 2 &&
		absi(ChunkIdx.z - PlayerChunkIdx.z) <= GenerationRadius / 2
	) && (
		true if (!IncludeFloors) else (
			ChunkIdx.y == PlayerChunkIdx.y ||  # In the same floor as the player
			(ChunkIdx.y < PlayerChunkIdx.y && PlayerChunkIdx.y - ChunkIdx.y <= absi(PreloadFloors.x)) ||  # Preloaded
			(ChunkIdx.y > PlayerChunkIdx.y && ChunkIdx.y - PlayerChunkIdx.y <= absi(PreloadFloors.y))  # Preloaded
		)
	)

func _UpdateParameters() -> void:
	# Set the seed of the RandomNumberGenerator to match the seed
	_RNG.seed = _Seed

func _ready() -> void:
	# Get chunk constants (all children nodes, MUST BE Node3D or derivated)
	var chunks = get_children(false)
	
	# Create container for the generated chunks
	_GeneratedChunksContainer = Node.new()
	_GeneratedChunksContainer.name = "Generated chunks"
	add_child(_GeneratedChunksContainer)
	
	# Create container for the chunk constants
	_ChunkConstants = Node.new()
	_ChunkConstants.name = "Constants"
	_ChunkConstants.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(_ChunkConstants)
	
	# Move all the chunk constants to its container
	for chunk in chunks:
		# Reparent the chunk
		chunk.reparent(_ChunkConstants)
		
		# Move the chunk to an unreachable position
		chunk.global_position = Vector3(-99999, -99999, -99999)
		
		# Make the chunk invisible
		chunk.visible = false
