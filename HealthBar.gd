class_name HealthBar extends Node2D

@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	find_child("Bar").scale.x = player.health
