extends HBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var player = get_node("/root/Root/Player")

var tex1 = preload("res://sprite/heart_point3.png")
var tex2 = preload("res://sprite/heart_point2.png")
var tex3 = preload("res://sprite/heart_point1.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var particles = player.particle_count - 17 - 1
	var hp = player.hitpoints
	
	for i in range(0, get_child_count()):
		if particles < i:
			get_child(i).hide()
		elif particles == i:
			get_child(i).show()
			if hp == 1:
				get_child(i).texture = tex1
			elif hp == 2:
				get_child(i).texture = tex2
			else:
				get_child(i).texture = tex3
		else:
			get_child(i).show()
			get_child(i).texture = tex3
