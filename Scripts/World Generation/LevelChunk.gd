class_name LevelChunk extends Node3D

var _Seed: int = 0
var _RNG: RandomNumberGenerator = RandomNumberGenerator.new()
@warning_ignore("unused_private_class_variable")
var _NearbyChunkIdxs: PackedInt32Array = [0, 0, 0, 0]  # [left, right, back, front]

@export_category("Modules configuration")

## Modules of the chunk. Modules are extra scripts that the chunk executes when generated or updated
@export var Modules: Array[ChunkModuleBase] = []

## The way the modules are randomized.
## The key is the index of the module, while the value is the randomized mode.
## -1 = Default (if not specified otherwise, will use this)
@export var ModulesSeedRandomize: Dictionary[int, LevelGeneration.RandomizeMode] = {
	-1: LevelGeneration.RandomizeMode.RNG
}

func _UpdateParameters() -> void:
	# Set the seed of the RandomNumberGenerator to match the chunk's seed
	_RNG.seed = _Seed

func _UpdateModulesParameters() -> void:
	# For each module
	for module in Modules:
		# Calculate the seed for the module
		var moduleSeed = LevelGeneration.CalculateSeedForObject(
			ModulesSeedRandomize.get(Modules.find(module), ModulesSeedRandomize.get(-1, LevelGeneration.RandomizeMode.RNG)),  # Tries to get the value for the module index. If not found, tries to get the value -1 (default). It -1 is also not found, fallback to RandomizeMode.RNG
			module,
			_RNG,
			Modules.find(module),
			Vector3.ZERO
		)
		
		# Set the seed of the module
		if ("_Seed" in module):
			module._Seed = moduleSeed
		
		if ("Seed" in module):
			module.Seed = moduleSeed
		
		# Update the module-managed parameters
		module._UpdateParameters()

func _RunModules() -> void:
	# For each module
	for module in Modules:
		# Run the module
		module._Run()
