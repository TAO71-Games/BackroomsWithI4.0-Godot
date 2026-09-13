extends Node

@export var Gen: LevelGeneration
@export var Players: Array[Node3D]
@export var Generate: bool = true
var i = 0

func _Gen() -> void:
	if (!Generate):
		return
	
	var playerPositions: Array[Vector3i] = []
	
	for player in Players:
		Gen.GenerateNearbyChunks(player.global_position)
		playerPositions.append(player.global_position)
	
	Gen.DeleteChunks(playerPositions)

func _ready() -> void:
	if (Gen != null):
		Gen.GenerationRadius = 25
		_Gen()
		
		var timer = Timer.new()
		add_child(timer)
		timer.wait_time = 5
		timer.one_shot = false
		timer.autostart = false
		timer.timeout.connect(func() -> void:
			_Gen()
			
			if (i > 4):
				timer.stop()
		)
		timer.start()
