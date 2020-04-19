extends KinematicBody2D

var linear_velocity = Vector2.ZERO
export var linear_velocity_strength: float = 4

export var max_horizontal_velocity = 120
export var gravity = 70

var on_ground = false

var camera: Camera2D
var jump_contrib = 0
export var jump_decrease_fac = 10
export var jump_quadratic = 20
export var max_jump_contrib = 50

var jump_decrease_actual = 0

var particle_count = 0
var used_particles = 0
var particles = []

var midairs = []

var plant_particle = preload("res://PlantParticle.tscn")
var midair_platform = preload("res://MidairPlatform.tscn")

var DEFAULT_PARTICLES = 17
var PARTICLES = DEFAULT_PARTICLES

var keys = 0

var attached_platform = null

var active_checkpoint

signal died

func _ready():
	active_checkpoint = get_node("/root/Root/Tutorial/InitCheck")
	active_checkpoint.activate()
	camera = get_node("../Camera")
	
	for i in range(0, PARTICLES):
		new_particle()

func round_joy_axis(a, b):
	var joy = Input.get_joy_axis(a, b)
	if abs(joy) < 0.05:
		return 0
	return joy
	
func process_jump(delta):
	if (on_ground or grapple_engaged) and Input.is_action_pressed("player_jump"):
		jump_contrib = max_jump_contrib
		on_ground = false
		jump_decrease_actual = 0
		
		if grapple_engaged:
			jump_contrib /= 3
		grapple_engaged = false
		
		if attached_platform:
			linear_velocity += attached_platform.velocity
			attached_platform = null
			
		$Jump.play()
	
	linear_velocity.y -= jump_contrib * delta
	jump_contrib -= delta * jump_decrease_actual
	jump_contrib = max(jump_contrib, 0)
	
	jump_decrease_actual += jump_quadratic * delta
	
	if not Input.is_action_pressed("player_jump"):
		jump_contrib = 0
		
var grapple_flip_input = false
	
func inputted_direction():
	var vel = Vector2.ZERO
	if Input.is_action_pressed("player_left"):
		vel.x -= 1
	if Input.is_action_pressed("player_right"):
		vel.x += 1
		
	vel.x += round_joy_axis(0, 0)
	vel = vel.normalized()
	
	if vel.x == 0:
		return 0
	elif vel.x > 0:
		if grapple_flip_input:
			return -1
		return 1
		
	if grapple_flip_input:
		return 1
	return -1

func inputted_velocity():
	var vel = Vector2.ZERO
	if Input.is_action_pressed("player_left"):
		vel.x -= 1
	if Input.is_action_pressed("player_right"):
		vel.x += 1
		
	vel.x += round_joy_axis(0, 0)
	vel = vel.normalized()
	
	return vel * linear_velocity_strength
	
enum AnimStates {
	IDLE,
	BOBBING
}
	
var animation_timer = 0
var sin_timer = 0
var anim_state = AnimStates.IDLE

var parabol_t = 2
var which_anim_foot = false

export var grapple_max = 9.0
export var grapple_rate = 4.0
	
func simple_parabola(t):
	t = 1 - 2 * t
	return 1 - t * t
	
func animation(delta):
	var speed = 1.4
	if abs(linear_velocity.x) > 0:
		var t = clamp(abs(linear_velocity.x) / max_horizontal_velocity, 0, 1)
		speed += t * 4
	sin_timer += delta * speed
	var sin2_target = 1 * cos(sin_timer)
	var sin1_target = 1 * sin(sin_timer)
	sin_timer = fmod(sin_timer, 2 * PI)
	
	parabol_t += delta * speed * 2
	if parabol_t > 1:
		parabol_t = 0
		which_anim_foot = not which_anim_foot
	
	if on_ground and abs(linear_velocity.x) > 20:
		var p = $Viz/FootRoot1
		var s = $Viz/FootRoot2
		if which_anim_foot:
			p = s
			s = $Viz/FootRoot1
		p.position.y = simple_parabola(parabol_t) * -2
		s.position.y = 0
		p.position.x += delta * 7 * speed
		s.position.x -= delta * 7 * speed
		
	else:
		$Viz/FootRoot1.position.y = 0
		$Viz/FootRoot2.position.y = 0
		$Viz/FootRoot1.position.x = 0
		parabol_t = 2
		which_anim_foot = false
		$Viz/FootRoot2.position.x = 0
	
	var fac = 0.5
	var fac2 = 0.03
	if on_ground:
		$Viz/BodyRoot.position.y += (sin2_target - $Viz/BodyRoot.position.y) * fac
		$Viz/BodyRoot/HeadRoot.position.y += (sin1_target - $Viz/BodyRoot/HeadRoot.position.y) * fac
	elif linear_velocity.y > 0:
		$Viz/BodyRoot.position.y += (-5 - $Viz/BodyRoot.position.y) * fac2
		$Viz/BodyRoot/HeadRoot.position.y += (-5 - $Viz/BodyRoot/HeadRoot.position.y) * fac2
	else:
		$Viz/BodyRoot.position.y += (3 - $Viz/BodyRoot.position.y) * fac2
		$Viz/BodyRoot/HeadRoot.position.y += (3 - $Viz/BodyRoot/HeadRoot.position.y) * fac2
		
	if linear_velocity.x < -2:
		$Viz.scale.x = -1
	elif linear_velocity.x > 2:
		$Viz.scale.x = 1
		
func h_damping():
	var t = clamp(abs(linear_velocity.x) / max_horizontal_velocity, 0, 1)
	if t < 0.05:
		t = 0
	
	return t * linear_velocity_strength * sign(linear_velocity.x)

var is_grappling = false
var grapple_engaged = false
var grapple_length = 0
var grapple_target = Vector2.ZERO

var grapple_ang_vel = 0
var grapple_part_start = 0
var grapple_part_end = 0

var GRAPPLE_DELTA = 18

var hitpoints = 3

onready var grapple_hook = get_node("../GrappleHook")

func get_grapple_target():
	var joyx = Input.get_joy_axis(0, 2)
	var joyy = Input.get_joy_axis(0, 3)
	
	if abs(joyx) > 0.02 and abs(joyy) > 0.02:
		return global_position + Vector2(joyx, joyy).normalized() * 500
	return get_global_mouse_position()

func handle_grapple(delta):
	var max_dist = (particle_count - used_particles) * GRAPPLE_DELTA
	
	if not is_grappling and Input.is_action_just_pressed("player_grapple"):
		is_grappling = true
		grapple_engaged = false
		
		grapple_target = get_grapple_target()
		grapple_hook.position = global_position
		
		$Grapple.play()
	
	var last_dist = (grapple_hook.position - global_position).length()
	
	if is_grappling:
		if last_dist > max_dist:
			is_grappling = false
		var hook_vel = (grapple_target - grapple_hook.position).normalized()
		grapple_hook.position += hook_vel * delta * 300

		grapple_target = grapple_hook.position + hook_vel * 500
		
		var new_dist = (grapple_hook.position - global_position).length()
		if new_dist > max_dist:
			is_grappling = false
		
		var dir = (grapple_hook.position - position).normalized()
		var pos = global_position
		for particle in particles.slice(used_particles, particles.size() - 1):
			particle.extra_target = pos
			pos += dir * GRAPPLE_DELTA
			if (pos - global_position).length() > last_dist:
				break
				
	if grapple_engaged:
		var direction = (position - grapple_hook.position).normalized()
		
		position = grapple_hook.position + direction * grapple_length
		var pos = global_position
		var dir2 = (grapple_hook.global_position - position).normalized()
		var last
		for particle in particles.slice(grapple_part_start, grapple_part_end):
			particle.extra_target = pos
			pos += dir2 * GRAPPLE_DELTA
			last = particle
		last.extra_target = grapple_hook.position
			
func handle_platform(dt):
	var NUM_NEEDED = 10
	if particle_count - used_particles >= NUM_NEEDED:
		if Input.is_action_just_pressed("player_platform"):
			if linear_velocity.y < 4:
				linear_velocity.y = 4
			
			var plat = midair_platform.instance()
			plat.position = global_position + Vector2(0, 17) + linear_velocity * dt
			get_node("../").add_child(plat)
			
			midairs.append(plat)
			
			var pos = plat.position + Vector2(-3 * (NUM_NEEDED - 1), 0)
			for p in particles.slice(used_particles, used_particles + NUM_NEEDED - 1):
				p.extra_target = pos
				pos += Vector2(6, 0)
			used_particles += NUM_NEEDED
			
			$Platform.play()
			
var flight_time = 0
export var each_flight_time = 0.04
export var flight_accel = 300

var flight_extra_fac = 4

var flight_vel_contrib = Vector2.ZERO

func fly_direction():
	var vel = Vector2.ZERO
	if Input.is_action_pressed("player_left"):
		vel -= Vector2(1, 0)
	if Input.is_action_pressed("player_right"):
		vel += Vector2(1, 0)
	if Input.is_action_pressed("player_up"):
		vel -= Vector2(0, 1)
	if Input.is_action_pressed("player_down"):
		vel += Vector2(0, 1)
		
	vel.x += Input.get_joy_axis(0, 0)
	vel.y += Input.get_joy_axis(0, 1)
	
	return vel.normalized()

func handle_flying(dt):
	if on_ground:
		flight_extra_fac = 7
	
	if not on_ground and Input.is_action_pressed("player_fly"):
		if flight_time <= 0:
			if used_particles < particle_count:
				var part = particles[used_particles]
				used_particles += 1
				
				part.vel_target = -fly_direction() * 10
				flight_time = each_flight_time * flight_extra_fac
				flight_extra_fac -= 1
				
				if flight_extra_fac < 1:
					flight_extra_fac = 1
				
	if flight_time > 0:
		var dir = fly_direction()
		flight_vel_contrib += flight_accel * dt * dir
		flight_time -= dt
		
		if linear_velocity.y > 0:
			linear_velocity.y = 0
			
		if not $Rocket.playing:
			$Rocket.play()
	else:
		flight_vel_contrib = Vector2.ZERO
		$Rocket.stop()

func new_particle():
	
	particle_count += 1
	var part = plant_particle.instance()
	particles.append(part)
	get_node("../").call_deferred("add_child", part)
	
func my_slice(arr, a, b):
	if a > b:
		return []
	return arr.slice(a, b)
	
var tutorial = false

func _physics_process(delta):
	if tutorial:
		linear_velocity = Vector2.ZERO
		return
	for particle in my_slice(particles, used_particles, particles.size() - 1):
		particle.extra_target = null
		particle.vel_target = null
	
	var input = inputted_velocity()
	if abs(linear_velocity.x) > 10 and on_ground:
		if not $Walk.playing:
			$Walk.play()
	else:
		$Walk.stop()
		
	var pt = linear_velocity.x / max_horizontal_velocity
	pt = clamp(pt, 0, 1)
	$Walk.pitch_scale = 1 + pt * 0.7
	
	var diff = (position - grapple_hook.position)
	var direction = diff.normalized()
	var ortho = Vector2(-direction.y, direction.x)
	
	if not grapple_engaged:
		linear_velocity += input * delta
		linear_velocity.x -= h_damping() * delta
		if flight_time <= 0:
			linear_velocity.y += gravity * delta
		else:
			linear_velocity.y += gravity * delta * 0.1
	else:
		var swing_dir = inputted_direction()
		
		var t = abs(grapple_ang_vel) / grapple_max
		t = clamp(t, 0, 1)
		var damp = sign(grapple_ang_vel) * t
		
		grapple_ang_vel += swing_dir * delta * grapple_rate
		grapple_ang_vel -= damp * delta * grapple_rate
		
		linear_velocity = -ortho * grapple_ang_vel * diff.length()
		
	handle_platform(delta)
	handle_flying(delta)
	linear_velocity = move_and_slide(linear_velocity)
	flight_vel_contrib = move_and_slide(flight_vel_contrib)
	
	if attached_platform:
		move_and_slide(attached_platform.velocity)
	
	if diff.length() > 0:
		grapple_ang_vel = linear_velocity.dot(-ortho) / diff.length()
		
	on_ground = false
	
	var last_attached_platform = attached_platform
	attached_platform = null
	for i in range(0, get_slide_count()):
		var c = get_slide_collision(i)
		if c.normal.dot(Vector2.UP) > 0.5:
			on_ground = true
			if c.collider.is_in_group("MovingPlatform"):
				attached_platform = c.collider.get_node("../")
				attached_platform.activate()
				if last_attached_platform == null:
					linear_velocity = Vector2(0, 0)
			if midairs.find(c.collider) == -1 and not grapple_engaged:
				used_particles = 0
				
				for m in midairs:
					m.queue_free()
				midairs.clear()
	if attached_platform == null and last_attached_platform != null:
		linear_velocity += last_attached_platform.velocity
		
	process_jump(delta)
	handle_grapple(delta)
		
	animation(delta)
	
	camera.position = position
	
	if particle_count <= 17:
		hitpoints = 3
		


func _on_grapplehook_connected(body):
	if is_grappling:
		if body.get_collision_layer_bit(2):
			is_grappling = false
			grapple_engaged = false
			return
		
		grapple_engaged = true
		is_grappling = false
		
		grapple_flip_input = position.y < grapple_hook.position.y
		
		grapple_length = (grapple_hook.global_position - global_position).length()
		
		var additional = 0
		
		var pos = global_position
		var dir2 = (grapple_hook.global_position - position).normalized()
		for particle in particles.slice(used_particles, particles.size() - 1):
			additional += 1
			pos += dir2 * GRAPPLE_DELTA
			if (pos - global_position).length() > grapple_length:
				break
		
		grapple_part_start = used_particles
		grapple_part_end = used_particles + additional
		used_particles += additional
		


func _on_damaged(body):
	position = active_checkpoint.global_position + Vector2(0, -6)
	linear_velocity = Vector2.ZERO
	grapple_engaged = false
	is_grappling = false
	flight_time = 0
	for m in midairs:
		m.queue_free()
	midairs.clear()
	
	$Death.play()
	emit_signal("died")
	
	hitpoints -= 1
	if hitpoints < 1:
	
		hitpoints = 3
		particle_count -= 1
		particles.pop_back().queue_free()
	
func trampoline(dir):
	if jump_contrib > 0:
		return
		
	on_ground = false
		
	linear_velocity -= linear_velocity.project(dir)
	linear_velocity += dir * 275
	
	used_particles = 0
	flight_extra_fac = 7
