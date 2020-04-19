extends Node2D

var o1 = 0
var o2 = 1.2
var o3 = 1.5

var used = false

func _process(delta):
	if not used:
		$Sprite1.position = Vector2(cos(o1), sin(o1)) * 5
		$Sprite2.position = Vector2(cos(o2), sin(o2)) * 7
		$Sprite3.position = Vector2(cos(o3), sin(o3)) * 8
	
	o1 += delta * 1.2
	o2 -= delta * 0.8
	o3 += delta * 0.9


func _on_player(body):
	if used:
		return
	
	body.new_particle()
	body.new_particle()
	body.new_particle()
	
	$Sprite1.queue_free()
	$Sprite2.queue_free()
	$Sprite3.queue_free()
	
	used = true
