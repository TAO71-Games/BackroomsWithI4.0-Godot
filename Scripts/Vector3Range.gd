class_name Vector3Range extends Resource

## Minimum vector
@export var Min: Vector3 = Vector3.ZERO

## Maximum vector
@export var Max: Vector3 = Vector3.ONE

func IsInRange(V: Vector3) -> bool:
	return (
		V.x >= Min.x && V.x <= Max.x &&
		V.y >= Min.y && V.y <= Max.y &&
		V.z >= Min.z && V.z <= Max.z
	)

static func IsInRangeMultiple(Ranges: Array[Vector3Range], V: Vector3) -> bool:
	for r in Ranges:
		if (r.IsInRange(V)):
			return true
	
	return false
