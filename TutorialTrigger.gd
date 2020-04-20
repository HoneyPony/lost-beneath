extends Area2D

var enabled = false

var can_continue = false

export var frames: Array

export var sprites: Array

onready var tex = get_node("/root/Root/CanvasLayer/Tutorial")
onready var player = get_node("/root/Root/Player")

var cur_frame = -1

func advance():
	if cur_frame == -1:
		for s in sprites:
			player.new_particle(s)
		sprites.clear()
	
	cur_frame += 1
	if cur_frame < frames.size():
		tex.texture = frames[cur_frame]
		tex.show()
		tex.get_node("Hmm").play()
	else:
		queue_free()
		tex.hide()
		player.tutorial = false

func _process(delta):
	if not enabled:
		return
		
	if Input.is_action_just_pressed("player_jump"):
		can_continue = true
		
	if can_continue:
		if Input.is_action_just_released("player_jump"):
			advance()
			can_continue = false

func _on_player(body):
	enabled = true
	advance()
	player.tutorial = true
