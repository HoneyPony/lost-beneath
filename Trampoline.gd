extends Node2D

onready var player = get_node("/root/Root/Player")

func _on_body_entered(body):
	if body == player:
		player.trampoline(-transform.y)
		$AnimationPlayer.play("Trampoline")
