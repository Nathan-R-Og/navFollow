extends Camera2D

export var followingPlayer = true
var followMode = 0
var windowWidth = ProjectSettings.get_setting("display/window/size/width")
var windowHeight = ProjectSettings.get_setting("display/window/size/height")
export var playerPath = NodePath()
onready var player1 = get_node(playerPath).get_node("PlayerBody")
export var Base = Vector2(960,540)


func _ready():
	zoom.x =  1.0 / (windowWidth / Base.x)
	zoom.y =  1.0 / (windowHeight / Base.y)


func _process(delta):


	var player1Null = player1.get_path()
	if get_node_or_null(player1Null) != null:
		if followingPlayer == true:
			match followMode:
				0:
					var cameraEnd = $"../cameraEnd".position
					var cameraStart = $"../cameraStart".position
					var offsetCamera = Vector2(Base.x,Base.y)/2
					# i swear this worked before
					position.x = clamp(player1.global_position.x, cameraStart.x + offsetCamera.x, cameraEnd.x - offsetCamera.x)
					position.y = clamp(player1.global_position.y, cameraStart.y + offsetCamera.y, cameraEnd.y - offsetCamera.y)
