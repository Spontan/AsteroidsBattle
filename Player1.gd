extends CharacterBody2D


const MAX_SPEED = 300.0
const ACCELERATION = 10.0
const TURN_SPEED = 0.1
var viewX = 1
var viewY = 0
var shootReleased = true

func _enter_tree():
	var screenRect = get_viewport_rect().size
	get_node("LeftCollision").position.x = -screenRect.x
	get_node("LeftPolygon").position.x = -screenRect.x
	get_node("UpperLeftCollision").position.x = -screenRect.x
	get_node("UpperLeftCollision").position.y = -screenRect.y
	get_node("UpperLeftPolygon").position.x = -screenRect.x
	get_node("UpperLeftPolygon").position.y = -screenRect.y
	get_node("UpperCollision").position.y = -screenRect.y
	get_node("UpperPolygon").position.y = -screenRect.y
	get_node("UpperRightCollision").position.x = screenRect.x
	get_node("UpperRightCollision").position.y = -screenRect.y
	get_node("UpperRightPolygon").position.x = screenRect.x
	get_node("UpperRightPolygon").position.y = -screenRect.y
	get_node("RightCollision").position.x = screenRect.x
	get_node("RightPolygon").position.x = screenRect.x
	get_node("LowerRightCollision").position.x = screenRect.x
	get_node("LowerRightCollision").position.y = screenRect.y
	get_node("LowerRightPolygon").position.x = screenRect.x
	get_node("LowerRightPolygon").position.y = screenRect.y
	get_node("LowerCollision").position.y = screenRect.y
	get_node("LowerPolygon").position.y = screenRect.y
	get_node("LowerLeftCollision").position.x = -screenRect.x
	get_node("LowerLeftCollision").position.y = screenRect.y
	get_node("LowerLeftPolygon").position.x = -screenRect.x
	get_node("LowerLeftPolygon").position.y = screenRect.y

func _physics_process(delta):
	# Handle turning
	var turnDirection = (Input.is_physical_key_pressed(Key.KEY_A) as int) - (Input.is_physical_key_pressed(Key.KEY_D) as int)
	if turnDirection != 0:
		updateRotation(turnDirection*TURN_SPEED)
		viewX = cos(get_node("CenterCollision").get_rotation())
		viewY = sin(get_node("CenterCollision").get_rotation())

	# Handle acceleration
	if Input.is_physical_key_pressed(Key.KEY_W):
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
		
	# Handle shoot
	if Input.is_physical_key_pressed(Key.KEY_SPACE):
		if shootReleased:
			shootReleased = false
			print("test")
	else:
		shootReleased = true

	move_and_slide()
	
func updateRotation(rot):
	for child in get_children():
		child.rotate(rot)
