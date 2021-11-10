extends Node2D

export var direction = "down"
export var world = "norm"
var worldChange = true
export var animPath = "res://Sprites/you/"
export var extendedY = 0


export var state = "norm"
export var playerId = 1
export var movementType = 1
var playerInput = Vector2()
var playerXInput = 0.0
var playerYInput = 0.0
var playerVelocity = Vector2()
var walkSpd = 120
var speedScalar = walkSpd
var running = false
var runInc = 1.0
var runBase = 20
var runTimer = 0.0
var runSet = 1
var do = null


var doing = false
var doable = false


var recording = true
var recordX = []
var recordY = []
var recordSize = 256

var moving = false
var angler = 0.0


export var framesPath = ""

export var animChange = ""
export var animStopping = false



func _ready():
	# partyMember playerInput to source from
	recordX.resize(recordSize)
	recordY.resize(recordSize)
	var iterater = 0
	while iterater < recordSize - 1:
		recordX[iterater] = position.x
		recordY[iterater] = position.y
		iterater += 1
	
	worldCheck()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	running = Input.is_action_pressed("decline")

	match movementType:
		0:
			pass
		1:
			if doing == false:
				
				
				
				if running == true:
					if runInc == 1.0:
						runSet = 1
					if runInc >= 1.0:
						runTimer += delta
					
					
					
					if runTimer >= 0.6 and runSet == 1:
						runInc = 5
						runSet = 2
					speedScalar = walkSpd + (runInc * runBase)
				else:
					runInc = 1.0
					runSet = 1
					runTimer = 0.0
					speedScalar = walkSpd
				playerXInput = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
				playerYInput = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
				playerInput = Vector2(playerXInput, playerYInput)
				playerVelocity = playerInput * speedScalar
				
				playerVelocity = $PlayerBody.move_and_slide(playerVelocity)


				angler = abs(-(rad2deg(atan2(playerInput.y,-playerInput.x)) + 180))
				
				
				if playerInput != Vector2(0.0,0.0):
					directionality()
					var iterateAnim = 0
					while iterateAnim < $PlayerBody/PlayerSprite.frames.get_animation_names().size():
						var TempSpeed = 0.0
						match runSet:
							1:
								TempSpeed = 5.0
							2:
								TempSpeed = 7.5
						$PlayerBody/PlayerSprite.frames.set_animation_speed($PlayerBody/PlayerSprite.frames.get_animation_names()[iterateAnim], TempSpeed)
						iterateAnim += 1
				
				#if playerInput.x > 0 and playerInput.y > 0:
					#if playerInput.x == playerInput.y:
					#	direction = "downRight"
				#	if playerInput.x > playerInput.y:
				#		direction = "right"
				#	if playerInput.x < playerInput.y:
				#		direction = "down"
				#elif playerInput.x < 0 and playerInput.y > 0:
					#if -playerInput.x == playerInput.y:
					#	direction = "downLeft"
				#	if -playerInput.x > playerInput.y:
				#		direction = "left"
				#	if -playerInput.x < playerInput.y:
				#		direction = "down"
				#elif playerInput.x < 0 and playerInput.y < 0:
					#if -playerInput.x == -playerInput.y:
					#	direction = "upLeft"
				#	if -playerInput.x > -playerInput.y:
				#		direction = "left"
				#	if -playerInput.x < -playerInput.y:
				#		direction = "up"
				#elif playerInput.x > 0 and playerInput.y < 0:
					#if playerInput.x == -playerInput.y:
					#	direction = "upRight"
				#	if playerInput.x > -playerInput.y:
				#		direction = "right"
				#	if playerInput.x < -playerInput.y:
				#		direction = "up"
				#if playerInput.x > 0 and playerInput.y == 0:
				#	direction = "right"
				#if playerInput.x < 0 and playerInput.y == 0:
				#	direction = "left"
				#if playerInput.x == 0 and playerInput.y > 0:
				#	direction = "down"
				#if playerInput.x == 0 and playerInput.y < 0:
				#	direction = "up"

				var offset = Vector2(1.5,1)
				var offsetAdd = Vector2(0,16)
				match direction:
					"down":
						$PlayerBody/interact.position = Vector2(0,16)
					"downRight":
						$PlayerBody/interact.position = Vector2(16,16)
					"downLeft":
						$PlayerBody/interact.position = Vector2(-16,16)
					"right":
						$PlayerBody/interact.position = Vector2(16,0)
					"left":
						$PlayerBody/interact.position = Vector2(-16,0)
					"up":
						$PlayerBody/interact.position = Vector2(0,-16)
					"upRight":
						$PlayerBody/interact.position = Vector2(16,-16)
					"upLeft":
						$PlayerBody/interact.position = Vector2(-16,-16)
				$PlayerBody/interact.position.x *=  offset.x
				$PlayerBody/interact.position.y *=  offset.y
				$PlayerBody/interact.position += offsetAdd
				if do != null and Input.is_action_just_pressed("decline") and doing == false:
					if do.get_parent() != self:
						doing = true
						if do.name.find("PlayerBody") == -1:
							do.get_parent().readyTextStuff()
						else:
							do.get_node("textRun").readyTextStuff()



				

				if playerVelocity != Vector2(0,0):
					
					
					
					

					
					
					moving = true
					$PlayerBody/PlayerSprite.play(direction)
				else:
					moving = false
					$PlayerBody/PlayerSprite.stop()
					if $PlayerBody/PlayerSprite.frame == 1:
						$PlayerBody/PlayerSprite.frame = 2
					elif $PlayerBody/PlayerSprite.frame == 3:
						$PlayerBody/PlayerSprite.frame = 0


				if recording == true:
					if $PlayerBody.global_position.x != recordX[0] or $PlayerBody.global_position.y != recordY[0]:
						var shift = recordSize - 2
						while shift > 0:
							recordX[shift] = recordX[shift - 1]
							recordY[shift] = recordY[shift - 1]
							shift -= 1
						recordX[0] = $PlayerBody.global_position.x
						recordY[0] = $PlayerBody.global_position.y
			else:
				moving = false
				$PlayerBody/PlayerSprite.stop()
				if $PlayerBody/PlayerSprite.frame == 1:
					$PlayerBody/PlayerSprite.frame = 2
				elif $PlayerBody/PlayerSprite.frame == 3:
					$PlayerBody/PlayerSprite.frame = 0

	animChangee()

func directionality():
	match angler:
		360.0:
			direction = "right"
		#45.0:
		#	direction = "upRight"
		90.0:
			direction = "up"
		#135.0:
		#	direction = "upLeft"
		180.0:
			direction = "left"
		#225.0:
		#	direction = "downLeft"
		270.0:
			direction = "down"
		#315.0:
		#	direction = "downRight"
	if data.lastDir != []:
		$PlayerBody/PlayerSprite.animation = data.lastDir[0]
	else:
		$PlayerBody/PlayerSprite.animation = direction



func worldCheck():
	var path = ""
	if framesPath == "":
		path = animPath + state + "/" + world + "/" + state + world + ".tres"
		framesPath = path
	else:
		path = framesPath
	var frames = load(path)
	$PlayerBody/PlayerSprite.frames = frames

func _on_interact_body_entered(body):
	if body.name != "Player" and body.name != "rigid":
		do = body
		doable = true


func _on_interact_body_exited(body):
	if body.name != "Player" and body.name != "rigid":
		do = null
		doable = false

func animChangee():
	if animChange != "" and animChange != "CLEAR":
		$PlayerBody/PlayerSprite.play(animChange)
		animChange = ""
	if animStopping != false:
		$PlayerBody/PlayerSprite.stop()
		animStopping = false
