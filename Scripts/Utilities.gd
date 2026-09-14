class_name Utilities extends Object

static var _NOSAVE_IsServer: bool = false
static var _NOSAVE_Instance: Utilities = Utilities.new()

## Limit of chunks that can be generated per frame
var Generation_NumChunksPerFrame: int = 50

## Chunk radius for the generation.
## For servers, it is recommended to have this setting between 10 and 50
var Generation_Radius: int = 20

## Distance in chunks for the collision to be activated.
## For servers, it is recommended to have this setting to be similar to `Generation_Radius`
var Generation_CollisionDistance: int = 2

static func IsServer() -> bool:
	return _NOSAVE_IsServer

static func GetInstance() -> Utilities:
	return _NOSAVE_Instance

static func GetParentUntilType(Type: Variant, Obj: Node, ForceStop: Node) -> Node:
	# While the object is not the same as the `ForceStop` object
	while (Obj != ForceStop):
		# Check it's type
		if (is_instance_of(Obj, Type)):
			# It's the same type! Return
			return Obj
		
		# Get the parent of the object
		Obj = Obj.get_parent()
	
	# Push a warning and return null (since a parent of the desired type can't be found)
	push_warning("Could not find a parent of the valid type. Returning null.")
	return null

static func GetAllChildrenOfType(Type: Variant, Obj: Node) -> Array[Node]:
	# Create an array where all the valid children will be stored
	var children: Array[Node] = []
	
	# For each child inside the object
	for child in Obj.get_children(false):
		# Check it's type
		if (is_instance_of(child, Type)):
			# It's the desired type! Append to the array
			children.append(child)
		
		# Call this function recursively and append the results to the array
		children.append_array(GetAllChildrenOfType(Type, child))
	
	# Return the array
	return children
