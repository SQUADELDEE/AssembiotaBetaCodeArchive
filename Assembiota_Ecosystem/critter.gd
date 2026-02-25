extends Node2D

class_name Critter

var age = 0
var max_age = 12
#highly modifiable
var reproductive_range = [2, 10]
var has_mate = false
var mated = false

#scaling factor for critters
@export var fish_scale := 0.1   # half size

@export var max_tilt_deg := 25.0        # maximum visual tilt
@export var rotation_speed := 3.0       # how fast the fish rotates

@export var speed: float = 70.0
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

#random mutation rate. Edit to a way that seems fitting
const MUTATION_RATE = 0.30  #

#New dev: Mutations for selection

var genome = {
	#basic mutation template
	"hardhead" : 0,
	"ears" : 0
}

func build_mutations_from_parents(parent1: Critter, parent2: Critter):
	for gene in parent1.genome.keys():	
		#decide if we take genes from mom or pop?
		if randf() < 0.5:
			genome[gene] = parent1.genome[gene]
		else:
			genome[gene] = parent2.genome[gene]
			
	#last, have a chance to screw with the mutations we just got from mom and dad.
	apply_random_mutation()
			
	#after mutations have been assigned, tell the computer to render the visuals
	render_traits()
	
func apply_random_mutation():
	for gene in genome.keys():
		if randf() <= MUTATION_RATE:
			#either pos or neg mutations
			genome[gene] += randi_range(-1, 1)
			#make sure it falls between 0 and 10 (fully or not expressed at all)
			genome[gene] = clamp(genome[gene], 0, 10)
			
	
func render_traits():
	#render traits based on value of dictionary.
	
	#level 1 hardhead render
	if (1 < genome["hardhead"] and genome["hardhead"] < 5):
		$Sprite2D/HeadMutText.texture = load("res://Assembiota_Ecosystem/resources/mutation_addons/Hardhead_I.png")
	#level 2 hardhead
	if genome["hardhead"] > 5:
		$Sprite2D/HeadMutText.texture = load("res://Assembiota_Ecosystem/resources/mutation_addons/Hardhead_II.png")
	
	
	#level 1 ears render
	if (1 < genome["ears"] and genome["ears"] < 5):
		$Sprite2D/EarMutText.texture = load("res://Assembiota_Ecosystem/resources/mutation_addons/Ear_Mutation_I.png")
	#level 2 ears render
	if genome["ears"] > 5:
		$Sprite2D/EarMutText.texture = load("res://Assembiota_Ecosystem/resources/mutation_addons/Ear_Mutation_.png")
	
	
		


func _ready():
	#temp

	
	scale = Vector2.ONE * fish_scale
	
	#temp
	
	#temp changed to the new sprites
	$Sprite2D.texture = load("res://Assembiota_Ecosystem/resources/template_species.png")

	# Random initial direction
	velocity = Vector2(
		randf_range(-1, 1),
		randf_range(-1, 1)
	).normalized() * speed

	_reset_turn_timer()

func die():
	_release_target()
	queue_free()
	
func do_death_sequence(population_array: Array, critter_container: Node2D):
	#tell the class its time to die
	dead = true
	
	#kill the plant hunting tween
	if pub_tween: 
		pub_tween.kill() 
	#release plant targets in case of stalemate
	_release_target()
	#remove critter from array so it doesnt retrigger
	population_array.erase(self)
	
	#change sprite to dead one
	$Sprite2D.texture = load("res://Assembiota_Ecosystem/resources/Dead.png")
	
	var tween = create_tween()
	# Tweens the alpha channel (a) of modulate to 0 over 3 seconds
	tween.tween_property($Sprite2D, "modulate:a", 0.0, 2.0)
	await tween.finished
	
	#remove from critter container
	critter_container.remove_child(self)
	#proper killoff
	die()
	
	

func check_eat():
	return is_eat
	
#helps with targeting mid kill. If a creature dies while in progress to plants,
#we handle it here, so the plant can be eaten by someone else.
func _release_target():
	if is_instance_valid(current_target_plant):
		current_target_plant.is_target = false

	current_target_plant = null
	is_eat = false
	busy = false

func _process(delta):
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
	if energy < 50:
		time_elapsed = INTERVAL
		
	if time_elapsed >= INTERVAL:
		is_eat = true
		
		
		time_elapsed = 0.0
	
	
	
	#size for juveniles vs adults
	if age < 2:
		fish_scale = 0.1
	else:
		fish_scale = 0.15
		
		
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
	
	#temp disabled rotation for graphical ease
	
	#_update_rotation(delta)

#function for plant consumption
func eat_plant(plant_controller, plant):
	busy = true
	current_target_plant = plant
	
	#just for visuals for now, but flip the creature based on direction for the tween
	if plant.return_pos().x > global_position.x:
		$Sprite2D.flip_h = true
		$Sprite2D/EarMutText.flip_h = true
		$Sprite2D/HeadMutText.flip_h = true
	elif plant.return_pos().x < global_position.x:
		$Sprite2D.flip_h = false
		$Sprite2D/EarMutText.flip_h = false
		$Sprite2D/HeadMutText.flip_h = false  
	
	#modifiable creature speed in pixels/sec
	var move_speed = 100.0 
	
	# 1. Calculate distance to target
	var distance = global_position.distance_to(plant.return_pos())
	
	# 2. Calculate duration needed to travel that distance at move_speed
	var duration = distance / move_speed
	
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", plant.return_pos(), duration).set_trans(Tween.TRANS_SINE)
	pub_tween = tween
	
	await tween.finished
	
	# If we died or got interrupted, stop
	if !is_instance_valid(self) or !is_instance_valid(plant) or dead == true:
		_release_target()
		return
	
	plant_controller.kill_plant(plant)
	_release_target()
	is_eat = false
	busy = false
	
#this all in one function prevents creatures from wasting a bunc of time
#picking randomized plant targets from the list. Instead. They pick the closest
#this is sort of like a chunk of bfs code logic.
func target_and_eat_closest_plant(plant_controller):
	var closest_plant = null
	#start with a ridiculous max
	var shortest = INF
	for planta in plant_controller.population():
		var dist = global_position.distance_squared_to(planta.global_position)
		if planta.is_target == false && (dist < shortest) :
			shortest = dist
			closest_plant = planta
	
	if closest_plant == null:
		is_eat = false
		busy = false
		return
	
	
	#eat post loop termination
	closest_plant.is_target = true
	current_target_plant = closest_plant
	is_eat = false
	#increment energy when eating
	energy += 10
	if energy > 100:
		energy = 100
	eat_plant(plant_controller, closest_plant)
	
				
	

func _increase_age(input):
	age += input
	
func _is_time_to_die() -> bool:
	return age >= max_age
	
func _has_mate() -> bool:
	return has_mate
	
func _set_mated(input):
	has_mate = input
	
func _is_permitted_to_reproduce() -> bool:
	#can't breed when too young or too old, or when they dont have enough energy
	return (age >= reproductive_range[0]) and (age <= reproductive_range[1]) and (energy >= 80) and (busy == false) and (dead == false)

func set_tank_rect(rect: Rect2):
	tank_rect = rect

func _get_half_size() -> float:
	if not has_node("Sprite2D"):
		return 0.0

	var tex = $Sprite2D.texture
	if tex == null:
		return 0.0

	# Use the largest dimension as a radius
	var size = tex.get_size()
	return max(size.x, size.y) * scale.x * 0.5

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

	if has_node("Sprite2D") and not busy:
		$Sprite2D.flip_h = velocity.x > 0
		$Sprite2D/EarMutText.flip_h = velocity.x > 0
		$Sprite2D/HeadMutText.flip_h = velocity.x > 0
		
func return_global_pos():
	return $Sprite2D.global_position
	

	

	
