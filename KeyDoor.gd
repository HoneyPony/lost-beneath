extends Node2D

onready var player = get_node("/root/Root/Player")

func _ready():
	player.connect("died", self, "queue_free")

func _on_body_entered(body):
	if body == player and player.keys > 0:
		player.keys -= 1
		player.get_node("Door").play()
		queue_free()
		
	
