class_name ChunkModule_ElementsRandomActivation extends ChunkModule_Base

var _Seed: int = 0
var _RNG: RandomNumberGenerator = RandomNumberGenerator.new()

## Objects to activate or deactivate
@export var Objs: Array[Node3D] = []

## Mode of activation for objects.
## It follows the same index as the objects and must be set in order.
## Default value is true
@export var ObjsMode: Array[bool] = []

## Probability of activating/deactivating the objects in `Objs`.
## From 0 to 100, supports decimals
@export_range(0, 100, 0.001) var Probability: float = 50

## If true, a new random number will be generated for each object.
## If false, a number will be generated at the start and all objects will activate/deactivate based on that number
@export var Individual: bool = false

func _UpdateParameters() -> void:
	# Match the RandomNumberGenerator seed to the module seed
	_RNG.seed = _Seed

func _Run() -> void:
	# Generate a random number from 0 to 100 (if not individual)
	var n = _RNG.randf_range(0, 100) if (!Individual) else 0.0
	
	# Ensure that the number of elements in the `ObjsMode` array is the same as `Objs`
	while (ObjsMode.size() < Objs.size()): ObjsMode.append(true)
	
	# Create an array to store the index of the deleted objects
	var deleted = []
	
	# For each object
	for obj in Objs:
		# Generate a random number from 0 to 100 (if individual)
		if (Individual): n = _RNG.randf_range(0, 100)
		
		# Calculate if the object should be activated or deactivated
		var activate = ObjsMode[Objs.find(obj)] if (n <= Probability) else !ObjsMode[Objs.find(obj)]
		
		# Activate/deactivate the object
		if (activate):
			# Activate (make visible and allow processing)
			obj.visible = true
			obj.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			# Deactivate
			# Make invisible and disable processing
			obj.visible = false
			obj.process_mode = Node.PROCESS_MODE_DISABLED
			
			# Append the current object index to the deleted array
			deleted.append(Objs.find(obj))
			
			# Delete the object (to save up RAM)
			obj.queue_free()
	
	# Remove the deleted objects from the list (to avoid errors if this function is executed multiple times)
	# For each deleted object index
	for idx in deleted:
		# Calculate the new index
		idx -= deleted.find(idx)
		
		# Remove from the arrays
		Objs.pop_at(idx)
		ObjsMode.pop_at(idx)
	
	# Clear the lists
	deleted.clear()
