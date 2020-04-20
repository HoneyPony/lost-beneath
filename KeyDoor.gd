extends Node2D

onready var player = get_node("/root/Root/Player")

var unlock = load("res://KeydoorUnlock.tscn")

func _ready():
	player.connect("died", self, "queue_free")

func _on_body_entered(body):
	if body == player and player.keys > 0:
		player.keys -= 1
		player.get_node("Door").play()
		
		var u = unlock.instance()
		u.global_position = global_position
		get_node("/root/Root").add_child(u)
		
		queue_free()
		
	
