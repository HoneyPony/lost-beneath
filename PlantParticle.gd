extends Node2D

var player

var extra_target = null
var vel_target = null

var light

func _ready():
	light = get_node("Light")
	remove_child(light)
	get_node("/root/Root/Lighting").add_child(light)
	
	player = get_node("../Player")
	theta = rand_range(0, 2 * PI)
	radius_t = rand_range(0, 2 * PI)
	orbit_vel = rand_range(0.5, 3);
	real_t = rand_range(0, 2 * PI)
	if randf() > 0.5:
		orbit_vel = -orbit_vel;
		
	player.connect("died", self, "reset_to_player")
	
	
var frames = 0
var theta = 0

var orbit_vel

var radius_t = 0
var err = Vector2.ZERO

var real_factor = 0
var real_t = 0


func rand_dir():
	return Vector2(rand_range(-0.2, 0.2), rand_range(-0.2, 0.2))
	
func _process(delta):
	
	
	var radius = 7 + sin(radius_t) * 7
	
	var target = player.global_position + Vector2(cos(theta), sin(theta)) * radius
	theta += delta * orbit_vel * rand_range(1, 1.2)
	radius_t += delta
	real_t += delta * rand_range(1, 1.1)
	
	var target_real = sin(real_t)
	
	var rate = 0.3
	var rrate = 0.1
	
	if extra_target != null:
		target = extra_target + err
		rate = 0.5
		rrate = 0.05
		target_real = 1
		
	if vel_target != null:
		target = global_position + vel_target
		rrate = 0.05
		target_real = 1
		
		vel_target.y += 10 * delta
		
	real_factor += (target_real - real_factor) * rrate
	
	$Mix.modulate.a = real_factor
	$Add.modulate.a = (1 - real_factor)
		
	if frames == 3:
		err = rand_dir().normalized() * 1
		frames = 0
	frames += 1
		
	position += (target - position) * rate
	
	light.global_position = global_position
	light.modulate.a = (1 - real_factor)

func reset_to_player():
	var radius = 7 + sin(radius_t) * 7
	var target = player.global_position + Vector2(cos(theta), sin(theta)) * radius
	position = target
