extends Node2D

var o1 = 0
var o2 = 1.2
var o3 = 1.5

var used = false

export var S0: Texture = null
export var S1: Texture = null
export var S2: Texture = null

func _ready():
	if S0 != null:
		$Sprite1.texture = S0
		$Sprite1.show()
	if S1 != null:
		$Sprite2.texture = S1
		$Sprite2.show()
	if S2 != null:
		$Sprite3.texture = S2
		$Sprite3.show()

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
	
	if S0 != null:
		body.new_particle(S0)
	if S1 != null:
		body.new_particle(S0)
	if S2 != null:
		body.new_particle(S0)
	body.get_node("Sprites").play()
	
	$Sprite1.queue_free()
	$Sprite2.queue_free()
	$Sprite3.queue_free()
	
	used = true
