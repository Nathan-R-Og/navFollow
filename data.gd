extends Node


var lastZone = -1
var lastDir = []
var lastTimer = 0.0

var playerName = ""
var rivalName = ""

var stateArrayA = []
var stateArrayB = []


#to convserve object states on exit of scenes and game

func _cacheStates():
	var iterateChildren = 0
	while iterateChildren < $"../World/Objects".get_child_count():
		var getNode = $"../World/Objects".get_child(iterateChildren)
		if getNode.name != "Player":
			var branch = getNode.branch
			var string = getNode.stringName
			var source = getNode.source
			stateArrayA.append([getNode, branch, string, source])
		iterateChildren += 1
