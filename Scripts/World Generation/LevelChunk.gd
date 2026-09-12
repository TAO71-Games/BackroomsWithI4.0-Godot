class_name LevelChunk extends Node3D

var _Seed: int = 0
var _RNG: RandomNumberGenerator = RandomNumberGenerator.new()
var _NearbyChunkIdxs: PackedInt32Array = [0, 0, 0, 0]  # [left, right, back, front]

@export_category("Modules configuration")
@export var Modules: Array[ChunkModuleBase] = []
var ModulesSeedRandomize: LevelGeneration.RandomizeMode

func _UpdateParameters() -> void:
	_RNG.seed = _Seed

func _UpdateModulesParameters() -> void:
	# For each module
	for module in Modules:
		# Calculate the seed for the module
		var moduleSeed = LevelGeneration.CalculateSeedForObject(ModulesSeedRandomize, module, null, Modules.find(module), Vector3.ZERO)
		
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
