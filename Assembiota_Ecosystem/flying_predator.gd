extends Node2D

#Flying predator will share a lot in common with regular creatures, with some 
#new behaviors like hunting
class_name FlyingPredator



var age = 0
var max_age = 15
#highly modifiable
var reproductive_range = [2, 9]
var has_mate = false
var mated = false

#scaling factor for critters
@export var fish_scale := 0.20  

#usually set to 25
@export var max_tilt_deg := 5.0        # maximum visual tilt
@export var rotation_speed := 3.0       # how fast the fish rotates

@export var speed: float = 100.0

@export var turn_strength: float = 0.4
@export var direction_change_min := 10.0
@export var direction_change_max := 15.0
@export var edge_buffer := 20.0  # how close to the wall counts as "at bounds"

var velocity: Vector2
var tank_rect: Rect2
var time_until_turn: float




#used to time eating for now
var time_elapsed: float = 0.0
const INTERVAL: float = 3.0
var is_eat = false
#prevent overeating
var busy = false

var entime_elapsed: float = 0.0
var ENG_INTERVAL: float = 1.5


#work in progress, start out below 100
var energy = 60

#use to handle death mid travel
var current_target_plant = null

var dead = false

var pub_tween

@export var swoop_speed: float = 300.0


#function that allows for dynamic prey targeting
#predators adaptively navigate towards the target.
#for changes to swooping speed change the "swoop speed" variable
func swoop_for_prey(target: Critter, delta, population_array, critter_container):
	if not is_eat and not busy:
		return
		
	busy = true
	
	
	#used to calculate overlapping bodies
	var kill_radius =  target._get_half_size()
	
	#old ver
	#var kill_radius = _get_half_size() + target._get_half_size()
	
	if !is_instance_valid(target):
		return
	
	var desired = (target.global_position - global_position).normalized()
	velocity = velocity.lerp(desired * swoop_speed, 5 * delta)
	position += velocity * delta
	
	#kill critters when overlapping with the predator
	if global_position.distance_to(target.global_position) <= kill_radius:
		target.do_death_sequence(population_array, critter_container)
		is_eat = false
		busy = false
		

		
	

#targets critters based on sight and proximity. Sight is measured by the presence of the
#camo trait. will target individuals with the lowest camo trait
func target_critter(critter_pop: Array) -> Critter:
	var closest_critter = null
	#start with a ridiculous max
	var shortest = INF
	for critter in critter_pop:
		#not distance, but how low the hardhead genome is!
		#hardhead can be replaced with camp
		var dist = global_position.distance_squared_to(critter.global_position)
		#calculate shortest dist and only make a target if it passes the vision check
		#roll a random int between 1 and 10, if the number is greater than the gene it can be a target
		if (dist < shortest) and critter.genome["hardhead"] < randi_range(0,10) :
			shortest = dist
			closest_critter = critter
			#if we have a target we can see, just end early, no need to waste runtime
	
	if closest_critter == null:
		is_eat = false
		busy = false
		return
		
	
	
	return closest_critter
	
				

func _ready():
	
	$AnimatedSprite2D.centered = true
	
	scale = Vector2.ONE * fish_scale
	$AnimatedSprite2D.scale = Vector2.ONE
	
	#temp changed to the new sprites
	$AnimatedSprite2D.play("idle")

	# Random initial direction
	velocity = Vector2(
		randf_range(-1, 1),
		randf_range(-1, 1)
	).normalized() * speed

	_reset_turn_timer()	



func _process(delta):
	
	
	#status vars are disabled for now
	
	#do nothing if dead
	if dead:
		return
	
	
	#decrease energy periodically even while in motion!
	entime_elapsed += delta
	if entime_elapsed >= ENG_INTERVAL: 
		if energy >= 0:
			energy -= 1
			entime_elapsed = 0.0
		
	
	if busy:
		return
		#time_elapsed = 0.0
	else:
		time_elapsed += delta
	
	#override standard interval if the critter is hungry
	#if energy < 50:
		#time_elapsed = INTERVAL
		
	if time_elapsed >= INTERVAL:
		is_eat = true
		
		
		time_elapsed = 0.0
	
	

		
		
	scale = Vector2.ONE * fish_scale
	
	time_until_turn -= delta

	if time_until_turn <= 0.0 and not _near_bounds():
		_switch_direction()
		_reset_turn_timer()

	# Small random drift
	var random_turn = Vector2(
		randf_range(-turn_strength, turn_strength),
		randf_range(-turn_strength, turn_strength)
	)
	velocity += random_turn
	velocity = velocity.normalized() * speed

	position += velocity * delta

	_handle_bounds()
	
	#temp enabled for visual effect
	
	_update_rotation(delta)
	
				
	

func _increase_age(input):
	age += input
	
func _is_time_to_die() -> bool:
	return age == max_age
	
func _has_mate() -> bool:
	return has_mate
	
func _set_mated(input):
	has_mate = input
	
func _is_permitted_to_reproduce() -> bool:
	#can't breed when too young or too old, or when they dont have enough energy
	return (age >= reproductive_range[0]) and (age <= reproductive_range[1]) and (energy >= 80) and (busy == false)

func set_tank_rect(rect: Rect2):
	tank_rect = rect

func _get_half_size() -> float:
	if not has_node("AnimatedSprite2D"):
		return 0.0

	var sprite = $AnimatedSprite2D
	var tex = sprite.sprite_frames.get_frame_texture(
		sprite.animation,
		sprite.frame
	)

	if tex == null:
		return 0.0

	var size = tex.get_size()
	return (max(size.x, size.y) * scale.x * 0.5) 

func _update_rotation(delta):
	if velocity.length() == 0:
		return

	var move_angle = velocity.angle()

	# Clamp tilt so fish never goes fully vertical
	var max_tilt = deg_to_rad(max_tilt_deg)
	
	#move_angle = clamp(move_angle, -max_tilt, max_tilt)
	
	#realism tweaks: depending on the direction fish are moving, determine rotational tilt
	if velocity.x < 0: 
		move_angle = clamp(move_angle * -0.5, -max_tilt, max_tilt)
	else:
		move_angle = clamp(move_angle * 0.5, -max_tilt, max_tilt)

	# Smooth rotation toward target tilt
	rotation = lerp_angle(rotation, move_angle, rotation_speed * delta)


func _switch_direction():
	velocity = Vector2(
		randf_range(-1, 1),
		randf_range(-1, 1)
	).normalized() * speed
	

func _reset_turn_timer():
	time_until_turn = randf_range(direction_change_min, direction_change_max)

#wall bouncing  sensing
func _near_bounds() -> bool:
	return (
		position.x < tank_rect.position.x + edge_buffer
		or position.x > tank_rect.position.x + tank_rect.size.x - edge_buffer
		or position.y < tank_rect.position.y + edge_buffer
		or position.y > tank_rect.position.y + tank_rect.size.y - edge_buffer
	)

#wall bouncing logic
func _handle_bounds():
	var half_size := _get_half_size()

	var left   = tank_rect.position.x + half_size
	var right  = tank_rect.position.x + tank_rect.size.x - half_size
	var top    = tank_rect.position.y + half_size
	var bottom = tank_rect.position.y + tank_rect.size.y - half_size

	if position.x < left:
		position.x = left
		velocity.x *= -1
	elif position.x > right:
		position.x = right
		velocity.x *= -1

	if position.y < top:
		position.y = top
		velocity.y *= -1
	elif position.y > bottom:
		position.y = bottom
		velocity.y *= -1

	if has_node("AnimatedSprite2D") and not busy:
		$AnimatedSprite2D.flip_h = velocity.x > 0
		
func return_global_pos():
	return $AnimatedSprite2D.global_position

	
