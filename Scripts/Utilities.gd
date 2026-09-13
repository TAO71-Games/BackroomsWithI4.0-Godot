class_name Utilities extends Object

static var _NOSAVE_IsServer: bool = false
var Generation_CollisionDistance: int = 2  # Only for clients. For servers, all collisions must be active

static func IsServer() -> bool:
	return _NOSAVE_IsServer
