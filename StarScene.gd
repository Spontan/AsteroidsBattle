class_name StarScene extends Node2D

@export var backgroundTexture: Texture2D

const cycleLength = 240

var backgroundEndPosition = Vector2.ZERO
var backgroundScrollState = Vector2.ZERO
var backgroundVelocity = Vector2.ZERO
var backgroundNode

# Called when the node enters the scene tree for the first time.
func _ready():
	if backgroundTexture == null:
		return
	
	print(backgroundTexture.get_size())
	
	var width = backgroundTexture.get_width()
	var height = backgroundTexture.get_height()
	
	var rect = get_viewport_rect().size
	
	backgroundEndPosition.x = -width*2
	backgroundEndPosition.y = -height*2
	
	backgroundVelocity = backgroundEndPosition/cycleLength
	
	backgroundNode = Node2D.new()
	addBackgroundImage(backgroundTexture, Vector2(width/2, height/2))
	addBackgroundImage(backgroundTexture, Vector2(5*width/2, 5*height/2))
	
	var backgroundImage = backgroundTexture.get_image()
	backgroundImage.flip_y()
	addBackgroundImage(ImageTexture.create_from_image(backgroundImage), Vector2(width/2, 3*height/2))
	addBackgroundImage(ImageTexture.create_from_image(backgroundImage), Vector2(5*width/2, 3*height/2))
	backgroundImage.flip_x()
	addBackgroundImage(ImageTexture.create_from_image(backgroundImage), Vector2(3*width/2, 3*height/2))
	backgroundImage.flip_y()
	addBackgroundImage(ImageTexture.create_from_image(backgroundImage), Vector2(3*width/2, height/2))
	addBackgroundImage(ImageTexture.create_from_image(backgroundImage), Vector2(3*width/2, 5*height/2))
	
	backgroundNode.z_index = -10
	
	add_child(backgroundNode)
	backgroundNode.position = Vector2.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if backgroundTexture == null:
		return
		
	backgroundNode.position += backgroundVelocity*delta
	
	if backgroundVelocity.dot(backgroundEndPosition - backgroundNode.position) < 0:
		backgroundNode.position -= backgroundEndPosition

func addBackgroundImage(texture, position):
	var backgroundSprite = Sprite2D.new()
	backgroundSprite.texture = texture
	backgroundNode.add_child(backgroundSprite)
	backgroundSprite.position = position
