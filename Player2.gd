extends CharacterBody2D


const MAX_SPEED = 300.0
const ACCELERATION = 10.0
const TURN_SPEED = 0.1
var viewX = 1
var viewY = 0


func _physics_process(delta):
	# Handle turning
	var turnDirection = (Input.is_physical_key_pressed(Key.KEY_LEFT) as int) - (Input.is_physical_key_pressed(Key.KEY_RIGHT) as int)
	if turnDirection != 0:
		rotate(turnDirection*TURN_SPEED)
		viewX = cos(get_rotation())
		viewY = sin(get_rotation())

	# Handle acceleration
	if Input.is_physical_key_pressed(Key.KEY_UP):
		velocity.x += viewX*ACCELERATION
		velocity.y += viewY*ACCELERATION
		
	# Handle screen wrap
	var screenRect = get_viewport_rect().size
	if  position.x < 0:
		position.x += screenRect.x
	elif  position.x > screenRect.x:
		position.x -= screenRect.x
	elif  position.y < 0:
		position.y += screenRect.y
	elif  position.y > screenRect.y:
		position.y -= screenRect.y

	move_and_slide()
