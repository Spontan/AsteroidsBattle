class_name Bullet extends Collidable

var distanceTraveled = 0
var delete = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _init(position, velocity):
	super._init(5, 0.1, 0.5, 0.1, 1, 0, 1)

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
