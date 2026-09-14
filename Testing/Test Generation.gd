extends Node

@export var Gen: LevelGeneration = null
@export var Players: Array[Node3D] = []
@export var Generate: bool = true

func _Gen() -> void:
	if (!Generate):
		return
	
	var playerPositions: Array[Vector3i] = []
	
	for player in Players:
		await Gen.GenerateNearbyChunks(player.global_position)
		playerPositions.append(player.global_position)
	
	await Gen.DeleteChunks(playerPositions)

func _ready() -> void:
	if (Gen != null):
		Gen._Seed = 10
		Gen._UpdateParameters()
		
		await _Gen()
		
		var timer = Timer.new()
		add_child(timer)
		timer.wait_time = 1
		timer.one_shot = false
		timer.autostart = false
		timer.timeout.connect(func() -> void:
			await _Gen()
		)
		timer.start()
