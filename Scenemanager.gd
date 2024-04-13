extends StarScene

const MENU = preload("res://mainmenu.tscn")
const GAME = preload("res://game.tscn")

var currentScene


# Called when the node enters the scene tree for the first time.
func _ready():

	backgroundTexture = load("res://background.jpg")
	super._ready()
	print(name)
	currentScene = MENU.instantiate()
	add_child(currentScene)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)

func loadGame():
	unloadCurrentScene()
	currentScene = GAME.instantiate()
	add_child(currentScene)
	
func endGame(winner):
	unloadCurrentScene()
	currentScene = MENU.instantiate()
	add_child(currentScene)
	currentScene.find_child("Winner").text = winner + " Won!"

func unloadCurrentScene():
	remove_child(currentScene)
	currentScene.queue_free()
