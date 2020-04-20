extends Node2D


# Declare member variables here. Examples:
# var a = 2


var l
var s

export var flicker = 0.0
export var flick_size = 0.7

# var b = "text"
func _ready():
	l = get_node("Light")
	s = l.position
	
	remove_child(l)
	get_node("/root/Root/Lighting").add_child(l)
	
	l.global_position = global_position + s
	l.show()
	l.rotation = rotation
	
func _process(delta):
	l.modulate.a += rand_range(-flicker, flicker)
	l.modulate.a = clamp(l.modulate.a, 0.7, 1)
