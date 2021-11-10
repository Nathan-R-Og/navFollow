extends Node2D

var connected = false

var move = true
export var MainPath = NodePath()
onready var Main = get_node(MainPath)
var speed = 1.0
var spdAmp = Vector2()
var path = PoolVector2Array() setget set_path
onready var PLAYERbody = get_node("Player2")

var recorddd = Vector2()


func _ready():
	set_process(false)


func _process(delta):
	if "playerVelocity" in Main:
		spdAmp = Main.playerVelocity
	else:
		spdAmp = Main.spdAmp
	var speedTangent = sqrt(pow(spdAmp.x,2) + pow(spdAmp.y,2))
	var move_distance = speedTangent * delta
	move_along_path(move_distance)


func move_along_path(distance):
	if move == true:
		var start_point = PLAYERbody.global_position
		for i in range(path.size()):
			var distance_to_next = start_point.distance_to(path[0])
			if distance <= distance_to_next and distance > 0.0:
				PLAYERbody.global_position = start_point.linear_interpolate(path[0], distance / distance_to_next)
				break
			elif distance < 0.0:
				PLAYERbody.global_position = path[0]
				set_process(false)
				break
			
			distance -= distance_to_next
			start_point = path[0]
			path.remove(0)


func set_path(value):
	path = value
	if value.size() == 0:
		return
	set_process(true)

func EnterPlayerRange(body):
	if body == PLAYERbody:
		print("guh")
		move = false

func ExitPlayerRange(body):
	if body == PLAYERbody:
		move = true
