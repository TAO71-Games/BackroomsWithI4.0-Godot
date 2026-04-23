class_name Globals extends Node

const Multiplayer_Debug: bool = true
const Multiplayer_Debug_Users: Dictionary[String, String] = {
	"test1": "test1",
	"test2": "test2",
	"test3": "test3",
	"test4": "test4",
	"test5": "test5",
	"test6": "test6"
}

static var ViewDistance: int = 50
static var Sensibility: float = 3
static var GenerationTime: float = 2

static var Multiplayer_Server: String = "ws://192.168.1.101:65287"
static var Multiplayer_UpdateTime: float = 0

static var User_Username: String = "Player"
static var User_Password: String = ""
