class_name MultiplayerConnection extends Node

static var VisitedLevels: Array[String] = []
static var Socket: WebSocketPeer = WebSocketPeer.new()

static func Connect(URI: String) -> void:
	Disconnect()
	
	Socket.connect_to_url(URI)
	Socket.poll()
	
	while (Socket.get_ready_state() == WebSocketPeer.STATE_CONNECTING):
		print("Connecting...")
		Socket.poll()
	
	if (IsConnected()):
		print("Connected!")
	else:
		print("Error connecting.")

static func Disconnect() -> void:
	Socket.close()

static func SendAndReceive(Action: String, Arguments: Array = [], AllowErrors: bool = true) -> Dictionary:
	if (!IsConnected()):
		push_error("Socket is not connected!")
		
		if (!AllowErrors):
			push_error("FAILED result code for multiplayer command.")
		
		return {"code": "FAILED", "args": []}
	
	var txt = JSON.stringify({"action": Action, "arguments": Arguments})
	var sendData = []
	
	while (len(txt) > 8192):
		sendData.append(txt.substr(0, 8192))
		txt = txt.substr(8192, -1)
	
	sendData.append(txt)
	sendData.append("--END--")
	
	for chunk in sendData:
		Socket.send_text(chunk)
		Socket.poll()
	
	var receivedChunks = []
	
	while (true):
		Socket.poll()
		
		if (Socket.get_available_packet_count() == 0):
			continue
		
		var chunk = Socket.get_packet().get_string_from_utf8()
		
		if (chunk.ends_with("--END--")):
			chunk = chunk.substr(0, chunk.rfind("--END--"))
			receivedChunks.append(chunk)
			
			break
		
		receivedChunks.append(chunk)
	
	var result = "".join(receivedChunks).strip_edges()
	
	if (len(result) > 0):
		result = JSON.parse_string(result)
		
		if ("code" not in result):
			result["code"] = "OK"
		
		if ("args" not in result):
			result["args"] = []
		
		if (!AllowErrors && result["code"] in ["FAILED", "NOT FOUND"]):
			push_error("FAILED result code for multiplayer command.")
		
		return result
	else:
		if (!AllowErrors):
			push_error("FAILED result code for multiplayer command.")
		
		return {"code": "FAILED", "args": []}

static func IsConnected() -> bool:
	Socket.poll()
	return Socket.get_ready_state() == WebSocketPeer.STATE_OPEN

static func IsAuthorized(AllowErrors: bool = true) -> bool:
	var authResult = MultiplayerConnection.SendAndReceive("is_authorized", [], AllowErrors)
	return authResult["args"][0]

static func Login(Username: String, Password: String, AllowErrors: bool = true) -> bool:
	var loginResult = MultiplayerConnection.SendAndReceive("connect", [Username, Password], AllowErrors)
	return loginResult["code"] == "OK"

static func SetPlayerPosition(V: Vector3, AllowErrors: bool = true) -> void:
	MultiplayerConnection.SendAndReceive("set_pos", [V.x, V.y, V.z], AllowErrors)

static func SetPlayerRotation(V: Vector3, AllowErrors: bool = true) -> void:
	MultiplayerConnection.SendAndReceive("set_rot", [V.x, V.y, V.z], AllowErrors)

static func SetPlayerScale(V: Vector3, AllowErrors: bool = true) -> void:
	MultiplayerConnection.SendAndReceive("set_scl", [V.x, V.y, V.z], AllowErrors)

static func SetCurrentLevel(Name: String, AllowErrors: bool = true) -> void:
	MultiplayerConnection.SendAndReceive("set_lvl", [Name], AllowErrors)
