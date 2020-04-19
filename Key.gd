extends Node2D

onready var player = get_node("/root/Root/Player")

var on_player = false
var theta = 0

var id = -1

var unavailable_timer = 0.1

func _ready():
	$Sprite/AnimationPlayer.play("Key")
	
	player.connect("died", self, "queue_free")
	
func _process(delta):
	unavailable_timer = max(unavailable_timer - delta, -0.2)
	if on_player:
		theta += delta * 3
		
		var target = player.global_position + Vector2(cos(theta) * 18, sin(theta) * 10)
		
		z_index = round(sin(theta)) * 5
		
		position += (target - position) * 0.06
	if player.keys < id:
		queue_free()
		
func _on_body_entered(body):
	if on_player:
		return
	
	if unavailable_timer > 0:
		return
	
	if body == player:
		on_player = true
		player.keys += 1
		id = player.keys
		
		$Key.play()
