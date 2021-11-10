extends Node2D
var fakeTimer = 0.0
var typing = false
var totalChars = 0


signal itemMove(location, item)
signal choices(textArray)
signal customCommand(syntax)
signal doClose()

signal npcAnimate(npcNumber,Anim)
signal setBranch(npcNumber,Branch)

var arraysOfArrays = []

var chars = 0
var charSpeed = 1
var timerSpeed = 1
var timerReady = false

var dialogueArray = []
var fileName = ""
var fileSource = ""
var file = ""
var index = 0
var branch = ""


var waitPos = 0
var waitLast = 0
var waitCharSize = 0
var waitLength = 0.0
var waitTotal = ""
var dramaticWait = false
var posInTriggerArray = 0
var endStartMeta = 0

var animationPos = 0
var animationLast = 0
var animationCharSize = 0
var animationType =""
var animationTotal = ""
var animationCharacterArray = [999999]
var posInAnimation = 0
var endStartMetaAnimation = 0
var animationArrayIndex = 0




var globalTriggerTypeArray = [999999]
var globalTriggerArray = [999999]
var globalTraitArray = [9999999]

var VoiceActing = false
var booping = false
var boopSFXName = ""



var globalNonMetaArray = [999999]
var globalNonMetaTriggerArray = [999]
var globalNonMetaDetailArray = [9999]
var posInNonMeta = 0


var blinkage = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var i = $characters.get_child_count()
	while i > 0:
		$characters.get_child(i - 1).animation = "blank"
		i -= 1
	#user choice
	VoiceActing = false
	booping = true
	boopSFXName = ""
	#timer change ready
	timerReady = true
	#init speeds
	timerSpeed = 0.07
	charSpeed = 0.5
	#directory file
	fileName = ""
	#os checker
	if OS.get_name() != "HTML5":
		$RichTextLabel.connect("meta_clicked", self, "_on_RichTextLabel_meta_clicked")
	#run text init
	####connect these to a trigger if you want to run text shit
	#_textInit()
	#typing = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):



	if typing == true:
		fakeTimer += (1.0/60.0)
	#always set the amount of visible characters to the char variable
	$RichTextLabel.visible_characters = chars

#if next, move index up one and run text load again
	if Input.is_action_just_pressed("decline") and dramaticWait == false and chars > 0:
		if index < dialogueArray.size() - 1:
			$blipper/AnimationPlayer.play("blank")
			index += 1
			_textRun()
			blinkage = false
		if index >= dialogueArray.size() - 1 and chars == $RichTextLabel.get_total_character_count() and chars > 0:
			$blipper/AnimationPlayer.play("blank")
			blinkage = false
			textClose()
			$RichTextLabel.clear()
	if Input.is_action_just_pressed("decline") and chars != $RichTextLabel.get_total_character_count():
		chars = $RichTextLabel.get_total_character_count()
	if chars == $RichTextLabel.get_total_character_count() and $RichTextLabel.get_total_character_count() > 0 and blinkage == false:
		blinkage = true
		$blipper/AnimationPlayer.play("blink")


#if none of the conditions are met, typewrite a character(s)
	if chars < $RichTextLabel.get_total_character_count():
		if dramaticWait == false:
			if not Input.is_action_just_pressed("decline"):
				chars += 1.0 * (charSpeed)



#if a waiting flag exists in the array, check if the amount of characters is at that point and do it
	if globalTriggerArray.empty() == false:
		if $RichTextLabel.visible_characters >= globalTriggerArray[posInTriggerArray]:
			match globalTriggerTypeArray[posInTriggerArray]:
				"wait":
					if dramaticWait == false:
						dramaticWait = true
						$TextWaitTimer.start(globalTraitArray[posInTriggerArray])
				"animation":
					get_node("characters/char" + String(int(animationCharacterArray[posInTriggerArray]))).play(globalTraitArray[posInTriggerArray])
					posInTriggerArray += 1
				"npcAnimate":
					emit_signal("npcAnimate",animationCharacterArray[posInTriggerArray],globalTraitArray[posInTriggerArray])
					posInTriggerArray += 1
				"setBranch":
					emit_signal("setBranch",animationCharacterArray[posInTriggerArray],globalTraitArray[posInTriggerArray])
					posInTriggerArray += 1
				"animFX":
					var destCharacter = get_node("characters/char" + String(int(animationCharacterArray[posInTriggerArray])))
					match globalTraitArray[posInTriggerArray]:
						"stop":
							destCharacter.frame = destCharacter.frames.get_frame_count(destCharacter.animation)
							destCharacter.stop()
						"play":
							destCharacter.play()
					posInTriggerArray += 1
				"sfx":
					boopSFXName = globalTraitArray[posInTriggerArray]
					var boopSFXpath = "res://sfx/" + boopSFXName + ".wav"
					var sfx = load(boopSFXpath)
					$AudioStreamPlayer.stream = sfx
					posInTriggerArray += 1
				"charName":
					$name.text = globalTraitArray[posInTriggerArray]
					posInTriggerArray += 1
				"forceClose":
					textClose()
					$RichTextLabel.clear()
					dialogueArray.clear()
					posInTriggerArray += 1
	if globalNonMetaTriggerArray.empty() == false:
		if index == globalNonMetaTriggerArray[posInNonMeta]:
			match globalNonMetaArray[posInNonMeta]:
				"Item":
					emit_signal("itemMove", "in", globalNonMetaDetailArray[posInNonMeta])
				"Item_Remove":
					emit_signal("itemMove", "out", globalNonMetaDetailArray[posInNonMeta])
				"Branch":
					emit_signal("choices", globalNonMetaDetailArray[posInNonMeta])
				"custom_command":
					emit_signal("customCommand", globalNonMetaDetailArray[posInNonMeta])
			posInNonMeta += 1






#text blip
	if not chars >= $RichTextLabel.get_total_character_count():
		if timerReady == true:
			if dramaticWait == false:
				if VoiceActing == false and booping == true:
					timerReady = false
					$AudioStreamPlayer.play()
					$SoundTimer.start(timerSpeed)





func _dumpCommands():
	if (dialogueArray.count(">command=")) > 0:
		var i = (dialogueArray.count(">command="))
		while i > 0:
			while (dialogueArray.find("Item")) != -1:
				var area = (dialogueArray.find(">command="))
				var commandType = dialogueArray[area + 1]
				var commandTrait = dialogueArray[area + 2]
				globalNonMetaArray.insert(globalNonMetaArray.size()-1, commandType)
				globalNonMetaTriggerArray.insert(globalNonMetaTriggerArray.size()-1, area)
				globalNonMetaDetailArray.insert(globalNonMetaDetailArray.size()-1, commandTrait)
				dialogueArray.remove(area + 2)
				dialogueArray.remove(area + 1)
				dialogueArray.remove(area)
				i -= 1
			while (dialogueArray.find("Item_Remove")) != -1:
				var area = (dialogueArray.find(">command="))
				var commandType = dialogueArray[area + 1]
				var commandTrait = dialogueArray[area + 2]
				globalNonMetaArray.insert(globalNonMetaArray.size()-1, commandType)
				globalNonMetaTriggerArray.insert(globalNonMetaTriggerArray.size()-1, area)
				globalNonMetaDetailArray.insert(globalNonMetaDetailArray.size()-1, commandTrait)
				dialogueArray.remove(area + 2)
				dialogueArray.remove(area + 1)
				dialogueArray.remove(area)
				i -= 1
			while (dialogueArray.find("Branch")) != -1:
				var area = (dialogueArray.find(">command="))
				var commandType = dialogueArray[area + 1]
				var decisions = int(dialogueArray[area + 2])
				var commandTrait = []
				var iterateShit = 1
				while iterateShit < decisions+1:
					commandTrait.append(dialogueArray[area + 2 + iterateShit])
					iterateShit += 1
				globalNonMetaArray.insert(globalNonMetaArray.size()-1, commandType)
				globalNonMetaTriggerArray.insert(globalNonMetaTriggerArray.size()-1, area)
				globalNonMetaDetailArray.insert(globalNonMetaDetailArray.size()-1, commandTrait)
				iterateShit = decisions
				while iterateShit > 0:
					dialogueArray.remove(area + 2 + iterateShit)
					iterateShit -= 1
				dialogueArray.remove(area + 2)
				dialogueArray.remove(area + 1)
				dialogueArray.remove(area)
				i -= 1
			while (dialogueArray.find("custom_command")) != -1:
				var area = (dialogueArray.find(">command="))
				var commandType = dialogueArray[area + 1]
				var commandTrait = []
				var howManyTraits = int(dialogueArray[area + 2])
				var iterate = 1
				while iterate < howManyTraits + 1:
					commandTrait.append(dialogueArray[area + 2 + iterate])
					iterate += 1
				globalNonMetaArray.insert(globalNonMetaArray.size()-1, commandType)
				globalNonMetaTriggerArray.insert(globalNonMetaTriggerArray.size()-1, area - 1)
				globalNonMetaDetailArray.insert(globalNonMetaDetailArray.size()-1, commandTrait)
				while iterate > 0:
					dialogueArray.remove(area + 2 + iterate)
					iterate -= 1
				dialogueArray.remove(area + 2)
				dialogueArray.remove(area + 1)
				dialogueArray.remove(area)
				i -= 1





func _textRun():
	#NOOO MOOORE CHARACTERS
	chars = 0
	$RichTextLabel.visible_characters = chars
	#YOUVE BEEN CLEARED
	$RichTextLabel.clear()
	#reset the autotimer
	fakeTimer = 0
	#ready the timer
	timerReady = true
	#no more waiting
	dramaticWait = false
	#index 0 in the array
	posInTriggerArray = 0
	animationArrayIndex = 0
	_dumpCommands()
	#index the metas into its proper arrays
	_metaDataDraw()
	#parse the parsable code (fuck you richtext)
	$RichTextLabel.parse_bbcode(dialogueArray[index])
	$RichTextLabel.push_align(1)
	#check if the voiceacting flag is on, and if so apply soundfile per index
	if VoiceActing == true:
		$AudioStreamPlayer.stop()
		var audio_file = "res://text/" + fileName + "/" + branch + String(index) + ".wav"
		var sfx = load(audio_file)
		$AudioStreamPlayer.stream = sfx
		$AudioStreamPlayer.play()
	


#first time shit
func _textInit():
	_loadfile()
	index = 0
	_textRun()

#if click link open
func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(meta)

#send all the dialogue to a single array (using a txt file because FUCK DOING THAT MANUALLY LMAOOOO)
func _loadfile():
	if fileSource == "":
		fileSource = "res://text/"
	file = fileSource + fileName + "/" + fileName + branch + ".txt"
	dialogueArray.clear()
	var fileObject = File.new()
	fileObject.open(file, File.READ)
	while not fileObject.eof_reached(): # iterate through all lines until the end of file is reached
		var line = fileObject.get_line()
		dialogueArray.append(line)

#runs a thing to check and do shit with metadata :)))))
func _metaDataDraw():
	globalTriggerArray.resize(1)
	globalTraitArray.clear()
	globalTraitArray.resize(1)
	globalTriggerTypeArray.clear()
	globalTriggerTypeArray.resize(1)
	animationCharacterArray.clear()
	animationCharacterArray.resize(1)
	#if there even is any continue
	var i = dialogueArray[index].count("{", 0, dialogueArray[index].length())
	while i > 0:
		var fuckerArray = []
		var j = dialogueArray[index].count("{/wait", 0, dialogueArray[index].length())
		var jInstance = dialogueArray[index].find("{/wait")
		var k = dialogueArray[index].count("{/animation", 0, dialogueArray[index].length())
		var kInstance = dialogueArray[index].find("{/animation")
		var l = dialogueArray[index].count("{/sfx", 0, dialogueArray[index].length())
		var lInstance = dialogueArray[index].find("{/sfx")
		var m = dialogueArray[index].count("{/charName", 0, dialogueArray[index].length())
		var mInstance = dialogueArray[index].find("{/charName")
		var n = dialogueArray[index].count("{/animFX", 0, dialogueArray[index].length())
		var nInstance = dialogueArray[index].find("{/animFX")
		var o = dialogueArray[index].count("{/npcAnimate", 0, dialogueArray[index].length())
		var oInstance = dialogueArray[index].find("{/npcAnimate")
		var p = dialogueArray[index].count("{/setBranch", 0, dialogueArray[index].length())
		var pInstance = dialogueArray[index].find("{/setBranch")
		var q = dialogueArray[index].count("{/forceClose", 0, dialogueArray[index].length())
		var qInstance = dialogueArray[index].find("{/forceClose")
		var r = dialogueArray[index].count("{/dataGet", 0, dialogueArray[index].length())
		var rInstance = dialogueArray[index].find("{/dataGet")
		var s = dialogueArray[index].count("{/lineBreak", 0, dialogueArray[index].length())
		var sInstance = dialogueArray[index].find("{/lineBreak")
		fuckerArray.append([jInstance,0])
		fuckerArray.append([kInstance,1])
		fuckerArray.append([lInstance,2])
		fuckerArray.append([mInstance,3])
		fuckerArray.append([nInstance,4])
		fuckerArray.append([oInstance,5])
		fuckerArray.append([pInstance,6])
		fuckerArray.append([qInstance,7])
		fuckerArray.append([rInstance,8])
		fuckerArray.append([sInstance,9])
		
		var foundOne = false
		var fucking = 0
		var iterateFucking = 0
		var DODATING = ""
		while fucking < dialogueArray[index].length() and foundOne == false:
			while iterateFucking < fuckerArray.size() and foundOne == false:
				if fucking == fuckerArray[iterateFucking][0]:
					match fuckerArray[iterateFucking][1]:
						0:
							DODATING = "wait"
						1:
							DODATING = "animation"
						2:
							DODATING = "sfx"
						3:
							DODATING = "charName"
						4:
							DODATING = "animFX"
						5:
							DODATING = "npcAnimate"
						6:
							DODATING = "setBranch"
						7:
							DODATING = "forceClose"
						8:
							DODATING = "dataGet"
						9:
							DODATING = "lineBreak"
					foundOne = true
					fuckerArray.clear()
					break
				iterateFucking += 1
			iterateFucking = 0
			fucking += 1
		fucking = 0
		match DODATING:
			"wait":
				_indexWait()
				j -= 1
			"animation":
				_indexAnimation()
				k -= 1
			"sfx":
				_indexSFX()
				l -= 1
			"charName":
				_indexCharName()
				m -= 1
			"animFX":
				_indexAnimationEffect()
				n -= 1
			"npcAnimate":
				_indexNPCAnimation()
				o -= 1
			"setBranch":
				_indexsetBranch()
				p -= 1
			"forceClose":
				_indexForceClose()
				q -= 1
			"dataGet":
				_indexDataGet()
				r -= 1
			"lineBreak":
				_indexLineBreak()
				s -= 1
		i -= 1
func _indexWait():
	#which one are we running?
	globalTriggerTypeArray.insert(globalTriggerTypeArray.size()-1, "wait")
	#wait pos = the front
	waitPos = dialogueArray[index].findn("{/wait=", 0)
	#wait last = the back
	waitLast = dialogueArray[index].findn("}", waitPos)
	#the length of the wait command in characters
	waitCharSize = (waitLast - (waitPos+7))
	#the length of the wait command in seconds
	waitLength = float(dialogueArray[index].substr(waitPos + 7, waitCharSize))
	#the string of the wait command itself (not counting duplicates)
	waitTotal = dialogueArray[index].substr(waitPos, (waitLast - waitPos)+1)
	#insert the wait time into an array
	globalTraitArray.insert(globalTraitArray.size()-1, waitLength)
	animationCharacterArray.insert(animationCharacterArray.size()-1, "")
	#run a check to see where the default ass shit of the string starts, init bbcode
	endStartMeta = 0
	_metaEndFind()
	#sets the character position to trigger the waiting
	globalTriggerArray.insert(globalTriggerArray.size()-1, waitPos - endStartMeta)
	#splices the line into halves, as to not fuck with duplicates
	var searchArea = dialogueArray[index].left(endStartMeta + waitTotal.length() + (waitPos-endStartMeta))
	var replacedArea = (searchArea.replace(waitTotal, ""))
	#stitches them back together
	dialogueArray[index] = replacedArea + dialogueArray[index].right(endStartMeta + waitTotal.length() + (waitPos-endStartMeta))
	#iterate :)


func _indexDataGet():
	#this ONLY works with autoloads, so be careful
	var command = "dataGet"
	animationPos = dialogueArray[index].findn("{/" + command, 0)
	animationLast = dialogueArray[index].findn("}", animationPos)
	var commandLength = command.length() + 3
	var commandLengthWSyn = commandLength
	animationCharSize = (animationLast - (animationPos+commandLengthWSyn))
	animationType = (dialogueArray[index].substr((animationPos + commandLength), animationCharSize))
	animationTotal = (dialogueArray[index].substr((animationPos), commandLengthWSyn + 1 + animationCharSize))
	
	#SPLIT
	var getten = animationType.find(".")
	var nodeUse = animationType.left(getten)
	var property = animationType.replace(nodeUse + ".", "")
	
	var getValue = String(get_node("/root/" + nodeUse).get(property))


	dialogueArray[index] = (dialogueArray[index].replace(animationTotal, getValue))
	#iterate :)



func _indexAnimation():
	#which one are we running?
	globalTriggerTypeArray.insert(globalTriggerTypeArray.size()-1, "animation")
	#wait pos = the front
	animationPos = dialogueArray[index].findn("{/animation", 0)
	#wait last = the back
	animationLast = dialogueArray[index].findn("}", animationPos)
	#the length of the wait command in characters
	animationCharSize = (animationLast - (animationPos+13))
	#the length of the wait command in seconds
	var animationCharacterNumber = (dialogueArray[index].substr(animationPos + 11, 1))
	animationCharacterArray.insert(animationCharacterArray.size()-1, animationCharacterNumber)
	animationType = (dialogueArray[index].substr((animationPos + 13), animationCharSize))
	globalTraitArray.insert(globalTraitArray.size()-1, animationType)
	
	animationTotal = (dialogueArray[index].substr((animationPos), 14 + animationCharSize))
	
	endStartMeta = 0
	_metaEndFind()
	#sets the character position to trigger the waiting
	globalTriggerArray.insert(globalTriggerArray.size()-1, animationPos - endStartMeta)
	#splices the line into halves, as to not fuck with duplicates
	var searchArea = dialogueArray[index].left(endStartMeta + animationTotal.length() + (animationPos-endStartMeta))
	var replacedArea = (searchArea.replace(animationTotal, ""))
	#stitches them back together
	dialogueArray[index] = replacedArea + dialogueArray[index].right(endStartMeta + animationTotal.length() + (animationPos-endStartMeta))
	#iterate :)


func _indexNPCAnimation():
	#which one are we running?
	globalTriggerTypeArray.insert(globalTriggerTypeArray.size()-1, "npcAnimate")
	#anim pos = the front
	animationPos = dialogueArray[index].findn("{/npcAnimate", 0)
	#anim last = the back
	animationLast = dialogueArray[index].findn("}", animationPos)
	#the length of the anim command in characters
	var lengthOfMeta = "{/npcAnimate".length()
	var endOfMeta = animationPos + lengthOfMeta
	var equalsInMeta = dialogueArray[index].find("=", endOfMeta)
	var animationCharacterNumber = (dialogueArray[index].substr(endOfMeta, equalsInMeta - endOfMeta))
	var lengthOfMetaWSynt = lengthOfMeta + animationCharacterNumber.length() + 1
	animationCharSize = (animationLast - (animationPos+lengthOfMetaWSynt))
	#the length of the anim command in seconds
	animationCharacterArray.insert(animationCharacterArray.size()-1, animationCharacterNumber)
	animationType = (dialogueArray[index].substr((animationPos + lengthOfMetaWSynt), animationCharSize))
	globalTraitArray.insert(globalTraitArray.size()-1, animationType)
	
	animationTotal = (dialogueArray[index].substr((animationPos), (lengthOfMetaWSynt + 1) + animationCharSize))
	
	endStartMeta = 0
	_metaEndFind()
	#sets the character position to trigger the animation
	globalTriggerArray.insert(globalTriggerArray.size()-1, animationPos - endStartMeta)
	#splices the line into halves, as to not fuck with duplicates
	var searchArea = dialogueArray[index].left(endStartMeta + animationTotal.length() + (animationPos-endStartMeta))
	var replacedArea = (searchArea.replace(animationTotal, ""))
	#stitches them back together
	dialogueArray[index] = replacedArea + dialogueArray[index].right(endStartMeta + animationTotal.length() + (animationPos-endStartMeta))
	#iterate :)

func _indexsetBranch():
	#which one are we running?
	globalTriggerTypeArray.insert(globalTriggerTypeArray.size()-1, "setBranch")
	#anim pos = the front
	animationPos = dialogueArray[index].findn("{/setBranch", 0)
	#anim last = the back
	animationLast = dialogueArray[index].findn("}", animationPos)
	#the length of the anim command in characters
	var lengthOfMeta = "{/setBranch".length()
	var endOfMeta = animationPos + lengthOfMeta
	var equalsInMeta = dialogueArray[index].find("=", endOfMeta)
	var animationCharacterNumber = (dialogueArray[index].substr(endOfMeta, equalsInMeta - endOfMeta))
	var lengthOfMetaWSynt = lengthOfMeta + animationCharacterNumber.length() + 1
	animationCharSize = (animationLast - (animationPos+lengthOfMetaWSynt))
	#the length of the anim command in seconds
	animationCharacterArray.insert(animationCharacterArray.size()-1, animationCharacterNumber)
	animationType = (dialogueArray[index].substr((animationPos + lengthOfMetaWSynt), animationCharSize))
	globalTraitArray.insert(globalTraitArray.size()-1, animationType)
	
	animationTotal = (dialogueArray[index].substr((animationPos), (lengthOfMetaWSynt + 1) + animationCharSize))
	
	endStartMeta = 0
	_metaEndFind()
	#sets the character position to trigger the animation
	globalTriggerArray.insert(globalTriggerArray.size()-1, animationPos - endStartMeta)
	#splices the line into halves, as to not fuck with duplicates
	var searchArea = dialogueArray[index].left(endStartMeta + animationTotal.length() + (animationPos-endStartMeta))
	var replacedArea = (searchArea.replace(animationTotal, ""))
	#stitches them back together
	dialogueArray[index] = replacedArea + dialogueArray[index].right(endStartMeta + animationTotal.length() + (animationPos-endStartMeta))
	#iterate :)

func _indexForceClose():
	#which one are we running?
	globalTriggerTypeArray.insert(globalTriggerTypeArray.size()-1, "forceClose")
	#anim pos = the front
	animationPos = dialogueArray[index].findn("{/forceClose", 0)
	#anim last = the back
	animationLast = dialogueArray[index].findn("}", animationPos)
	#the length of the anim command in characters
	var lengthOfMeta = "{/forceClose".length() + 1
	
	endStartMeta = 0
	_metaEndFind()
	#sets the character position to trigger the animation
	globalTriggerArray.insert(globalTriggerArray.size()-1, animationPos - endStartMeta)

	#stitches them back together
	dialogueArray[index] = dialogueArray[index].replace("{/forceClose}", " ")
	#iterate :)

func _indexLineBreak():
	#anim pos = the front
	animationPos = dialogueArray[index].findn("{/lineBreak", 0)
	#anim last = the back
	animationLast = dialogueArray[index].findn("}", animationPos)
	

	#stitches them back together
	dialogueArray[index] = dialogueArray[index].replace("{/lineBreak}", "\n")
	#iterate :)
func _indexAnimationEffect():
	#which one are we running?
	globalTriggerTypeArray.insert(globalTriggerTypeArray.size()-1, "animFX")
	#wait pos = the front
	animationPos = dialogueArray[index].findn("{/animFX", 0)
	#wait last = the back
	animationLast = dialogueArray[index].findn("}", animationPos)
	#the length of the wait command in characters
	animationCharSize = (animationLast - (animationPos+10))
	#the length of the wait command in seconds
	var animationCharacterNumber = (dialogueArray[index].substr(animationPos + 8, 1))
	animationCharacterArray.insert(animationCharacterArray.size()-1, animationCharacterNumber)
	animationType = (dialogueArray[index].substr((animationPos + 10), animationCharSize))
	globalTraitArray.insert(globalTraitArray.size()-1, animationType)
	
	animationTotal = (dialogueArray[index].substr((animationPos), 11 + animationCharSize))
	
	endStartMeta = 0
	_metaEndFind()
	#sets the character position to trigger the waiting
	globalTriggerArray.insert(globalTriggerArray.size()-1, animationPos - endStartMeta)
	#splices the line into halves, as to not fuck with duplicates
	var searchArea = dialogueArray[index].left(endStartMeta + animationTotal.length() + (animationPos-endStartMeta))
	var replacedArea = (searchArea.replace(animationTotal, ""))
	#stitches them back together
	dialogueArray[index] = replacedArea + dialogueArray[index].right(endStartMeta + animationTotal.length() + (animationPos-endStartMeta))
	#iterate :)

func _indexSFX():
	#which one are we running?
	globalTriggerTypeArray.insert(globalTriggerTypeArray.size()-1, "sfx")
	#sfx pos = the front
	var sfxPos = dialogueArray[index].findn("{/sfx=", 0)
	#sfx last = the back
	var sfxLast = dialogueArray[index].findn("}", sfxPos)
	#the length of the sfx command in characters
	var sfxCharSize = (sfxLast - (sfxPos+6))
	#the name of the sfx file without the extension
	var sfxName = dialogueArray[index].substr(sfxPos + 6, sfxCharSize)
	#the string of the sfx command itself (not counting duplicates)
	var sfxTotal = dialogueArray[index].substr(sfxPos, (sfxLast - sfxPos)+1)
	#insert the sfx trigger into an array
	globalTraitArray.insert(globalTraitArray.size()-1, sfxName)
	animationCharacterArray.insert(animationCharacterArray.size()-1, "")
	#run a check to see where the default ass shit of the string starts, init bbcode
	endStartMeta = 0
	_metaEndFind()
	#sets the character position to trigger the sfx change
	globalTriggerArray.insert(globalTriggerArray.size()-1, sfxPos - endStartMeta)
	#splices the line into halves, as to not fuck with duplicates
	var searchArea = dialogueArray[index].left(endStartMeta + sfxTotal.length() + (sfxPos-endStartMeta))
	var replacedArea = (searchArea.replace(sfxTotal, ""))
	#stitches them back together
	dialogueArray[index] = replacedArea + dialogueArray[index].right(endStartMeta + sfxTotal.length() + (sfxPos-endStartMeta))
	#iterate :)



func _indexCharName():
	#which one are we running?
	globalTriggerTypeArray.insert(globalTriggerTypeArray.size()-1, "charName")
	#charName pos = the front
	var charNamePos = dialogueArray[index].findn("{/charName=", 0)
	#charName last = the back
	var charNameLast = dialogueArray[index].findn("}", charNamePos)
	#the length of the charName command in characters
	var charNameCharSize = (charNameLast - (charNamePos+11))
	#the name of the charName file without the extension
	var charNameName = dialogueArray[index].substr(charNamePos + 11, charNameCharSize)
	#the string of the charName command itself (not counting duplicates)
	var charNameTotal = dialogueArray[index].substr(charNamePos, (charNameLast - charNamePos)+1)
	#insert the charName trigger into an array
	globalTraitArray.insert(globalTraitArray.size()-1, charNameName)
	animationCharacterArray.insert(animationCharacterArray.size()-1, "")
	#run a check to see where the default ass shit of the string starts, init bbcode
	endStartMeta = 0
	_metaEndFind()
	#sets the character position to trigger the charName change
	globalTriggerArray.insert(globalTriggerArray.size()-1, charNamePos - endStartMeta)
	#splices the line into halves, as to not fuck with duplicates
	var searchArea = dialogueArray[index].left(endStartMeta + charNameTotal.length() + (charNamePos-endStartMeta))
	var replacedArea = (searchArea.replace(charNameTotal, ""))
	#stitches them back together
	dialogueArray[index] = replacedArea + dialogueArray[index].right(endStartMeta + charNameTotal.length() + (charNamePos-endStartMeta))
	#iterate :)





func _metaEndFind():
	if dialogueArray[index].findn("[",endStartMeta) > -1:
		endStartMeta = dialogueArray[index].findn("]", 0) +1
		if dialogueArray[index].substr(endStartMeta, 1) == "[":
			_metaEndFind()
		else:
			return endStartMeta
	else:
		return endStartMeta



func _on_Timer_timeout():
#	print("type")
	timerReady = true


func _on_TextWaitTimer_timeout():
	#print("stopwaiting")
	dramaticWait = false
	posInTriggerArray += 1




func _doTextStuff(nameThing, sourceFrom = ""):
	fileName = nameThing
	fileSource = sourceFrom
	_textInit()
	typing = true
	show()
	

func textClose():
	emit_signal("doClose")


func _defaultClose():
	fileName = ""
	file = ""
	index = 0
	dialogueArray.clear()
	hide()
	var i = $characters.get_child_count()
	while i > 0:
		$characters.get_child(i - 1).animation = "blank"
		i -= 1
