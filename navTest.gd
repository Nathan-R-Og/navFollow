extends Node2D


export var navPath = NodePath()
onready var nav_2d = get_node(navPath)
export var linePath = NodePath()
onready var line_2d = get_node(linePath)


func _process(delta):
	

	var objCheck = 0
	while objCheck < $obj.get_child_count():
		if "MainPath" in $obj.get_child(objCheck):
			var character = $obj.get_child(objCheck)
			var charPos = character.get_child(0).global_position
			var main = character.get_node_or_null(character.MainPath)
			if main != null:
				var mainBody = main.get_child(0)
				var mainPos = mainBody.global_position
				var mainStop = mainBody.get_node("NPCRest")
				if character.connected == false:
					mainStop.connect("body_entered", character, "EnterPlayerRange")
					mainStop.connect("body_exited", character, "ExitPlayerRange")
					character.connected = true
				var new_path = nav_2d.get_simple_path(charPos, mainPos)
				line_2d.points = new_path
				character.path = new_path
		objCheck += 1
