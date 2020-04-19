extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var velocity = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta


func _on_body_inside(body):
	body.linear_velocity = velocity

func activate():
	velocity = Vector2(-400, 0)
