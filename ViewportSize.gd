extends Viewport

func _ready():
	var size = get_parent().get_viewport().size
	self.size = size

func _process(delta):
	var size = get_parent().get_viewport().size
	self.size = size
