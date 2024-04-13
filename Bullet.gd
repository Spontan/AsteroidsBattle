class_name Bullet extends StaticBody2D

var velocity = Vector2.ZERO
var distanceTraveled = 0
var delete = false
const BASE_DAMAGE = 5
const BASE_SPEED = 600
const WEIGHT = 0.1


# Called when the node enters the scene tree for the first time.
func _ready():
	set_collision_layer_value(1, false)

func _init(position, velocity):
	var bulletCollision = CollisionShape2D.new()
	var collisionShape = CircleShape2D.new()
	collisionShape.radius = 5.0
	bulletCollision.shape = collisionShape
	add_child(bulletCollision)
	self.position = position
	self.velocity = velocity
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += velocity.x*delta
	position.y += velocity.y*delta
	distanceTraveled = (velocity.x+velocity.y)*delta
	set_collision_layer_value(1, true)
	
	var screenRect = get_viewport_rect().size
	if  position.x < 0:
		position.x += screenRect.x
	elif  position.x > screenRect.x:
		position.x -= screenRect.x
	elif  position.y < 0:
		position.y += screenRect.y
	elif  position.y > screenRect.y:
		position.y -= screenRect.y
	
	doMovement(velocity * delta)

func _draw():
	draw_circle(Vector2(0.0, 0.0), 5.0, Color.GRAY)

func collide(collisionVector, _collisionImpact, surfaceNormal, collisionPoint):
	var collisionShallowness = collisionVector.dot(surfaceNormal)
	
	# check if bullet should be reflected
	if collisionShallowness/collisionVector.length() > 0.4:
			queue_free()
	else:
		velocity = 0.5*(velocity + collisionShallowness*surfaceNormal)
		
func doMovement(movementVector):
	var collisionInfo = move_and_collide(movementVector)
	if collisionInfo:
		var collider = collisionInfo.get_collider()
		var collisionVector = velocity - collider.velocity
		var surfaceNormal = collisionInfo.get_normal()
		var collisionPoint = collisionInfo.get_position()
		collider.collide(collisionVector, WEIGHT, -surfaceNormal, collisionPoint)
		collide(-collisionVector, collider.WEIGHT, surfaceNormal, collisionPoint)
		doMovement(0.5*collisionInfo.get_remainder().bounce(surfaceNormal))
