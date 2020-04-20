extends Node2D

var used = false
var flame: Sprite

func _ready():
	
	flame = get_node("Flame")
	if flame != null:
		var p = flame.global_position
		remove_child(flame)
		
		get_node("/root/Root/Lighting").add_child(flame)
		flame.global_position = p
		flame.hide()
	pass # Replace with function body.
	
func _process(delta):
	if flame != null:
		flame.modulate.a += rand_range(-0.03, 0.03)
		flame.modulate.a = clamp(flame.modulate.a, 0.6, 1)
	
func deactivate():
	$AnimationPlayer.play("Inactive")
	if flame != null:
		flame.hide()
	
func activate():
	if not used:
		get_node("/root/Root/Player").hitpoints = 3
	used = true
	if flame != null:
		flame.show()
	$AnimationPlayer.play("Active")
	

func _on_player_entered(player):
	if player.active_checkpoint != self:
		player.get_node("Check").play()
	
	player.active_checkpoint.deactivate()
	player.active_checkpoint = self
	activate()
	
