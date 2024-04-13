class_name Level extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func on_healthbar_empty(player):
	print(player.name)
	if player.name == "Player1":
		Scenemanager.endGame(find_child("Player2").find_child("Player2Ship").playerName)
	else:
		Scenemanager.endGame(find_child("Player1").find_child("Player1Ship").playerName)
