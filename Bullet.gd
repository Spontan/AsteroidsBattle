extends Area2D

@export var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += velocity.x/Engine.get_frames_per_second()
	position.y += velocity.y/Engine.get_frames_per_second()
	
	

func _draw():
	print("drawing")
	draw_circle(Vector2(0.0, 0.0), 5.0, Color.GRAY)
