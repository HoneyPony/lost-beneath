extends Camera2D
var to_copy: Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	to_copy = get_node("/root/Root/Camera")
	pass # Replace with function body.

func _process(delta):
	position = to_copy.position
	offset = to_copy.offset
