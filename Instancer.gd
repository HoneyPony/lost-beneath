extends Node2D

export var scene: PackedScene

func _ready():
	var player = get_node("/root/Root/Player")
	player.connect("died", self, "spawn")
	
	call_deferred("spawn")
	
func spawn():
	var s = scene.instance()
	s.position = global_position
	get_node("/root/Root").call_deferred("add_child", s)
