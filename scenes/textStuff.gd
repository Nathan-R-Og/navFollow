extends Node2D

export var extendedY = 0
export var branch = ""
export var stringName = ""
onready var textStuff = $"/root/World/Hud/TextStuff"
export var source = ""

export var BEHAVIOR = 0
var alsoDoing = false


var sourcedData = []

func _ready():
	var iterateChildren = 0
	while iterateChildren < data.stateArrayA.size():
		var getNode = data.stateArrayA[iterateChildren][0]
		if getNode == self:
			sourcedData = data.stateArrayA[iterateChildren]
			stringName = sourcedData[1]
			branch = sourcedData[2]
			source = sourcedData[3]
			break
		iterateChildren += 1

func readyTextStuff(nodeAccess := self):
	textStuff._doTextStuff(stringName + branch, source)


