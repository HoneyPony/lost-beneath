extends Control

export var node_path: NodePath

func _ready():
	get_node(node_path).grab_focus()
