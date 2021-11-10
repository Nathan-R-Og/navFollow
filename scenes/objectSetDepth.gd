extends Node2D

export var textNode = NodePath()
onready var text = get_node(textNode)


var orderArray = []





func _ready():
	text.connect("npcAnimate",self,"_baseAnimate")
	text.connect("setBranch",self,"setNPCBRANCH")
	text.connect("doClose",self,"revive")



func _process(delta):
	orderArray.clear()
	var iterateChildren = 0
	while iterateChildren < get_child_count():
		var getNode = get_child(iterateChildren)
		var Incase = Node
		if getNode.get_class() == "Node2D":
			Incase = getNode.get_child(0)
			orderArray.append([getNode, Incase.position.y + getNode.position.y - getNode.extendedY])
		else:
			orderArray.append([getNode, getNode.position.y - getNode.extendedY])
		iterateChildren += 1


	orderArray.sort_custom(MyCustomSorter, "sort_ascending")
	
	var setChildren = 0
	while setChildren < get_child_count():
		move_child(orderArray[setChildren][0],setChildren)
		setChildren += 1

class MyCustomSorter:
	static func sort_ascending(a, b):
		if a[1] < b[1]:
			return true
		return false



func setNPCBRANCH(child,Branch):
	var iterate = 0
	var node = Node
	while iterate < get_child_count():
		var getNode = get_child(iterate)
		if getNode.name == child:
			node = getNode
			break
		iterate += 1
	node.branch = Branch

func revive():
	data._cacheStates()
	$Player.doing = false
	$Player.doable = true


func _baseAnimate(child,Anim):
	var iterate = 0
	var node = Node
	while iterate < get_child_count():
		var getNode = get_child(iterate)
		if getNode.get_class() == "Node2D" and getNode.name == child:
			var Incase = getNode.get_child(0)
			if Anim != "reset":
				getNode.global_position = Incase.global_position
				Incase.position = Vector2(0,0)
			node = getNode
			break
		iterate += 1
	node.get_node("AnimationPlayer").play(Anim)
