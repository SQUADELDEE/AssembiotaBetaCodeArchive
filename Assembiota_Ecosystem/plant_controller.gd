extends Node2D

class_name PlantController

#load the graphical plant
var plant_scene : PackedScene = preload("res://Assembiota_Ecosystem/plant.tscn")

#system cap for plant growth
var plant_maximum = Globals.parameters["plant_cap"]

#this list will store all of the plants in the simulation
var plant_pop = []

#used in ready for initial spawns
var plant_spawn_points = [Vector2(200, 200), Vector2(200, 800), Vector2(1600, 200), 
Vector2(1600,800), Vector2(900,450)]

var time_elapsed: float = 0.0
#using this to control the spread time interval
const INTERVAL: float = 1.5

var world_rect: ColorRect

	
func _intialize_world(world: ColorRect):
	world_rect = world
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#spawns plants at predetermined locales which will expand
	for point in plant_spawn_points:
		spawn_plant(point, plant_pop)
	
	
	pass # Replace with function body.

#spawn a new plant given a directed position, and adds it to a given array (logic)
func spawn_plant(pos: Vector2, list: Array):
	if plant_pop.size() >= plant_maximum:
		return
	#delegate addition to the controller, which is by design added to the
	#the main world scene
	var new_plant = plant_scene.instantiate()
	new_plant.global_position = pos
	add_child(new_plant)
	list.append(new_plant)
	

	

#kill a given plant (for eating functionality)
func kill_plant(plant):
	remove_child(plant)
	plant_pop.erase(plant)
	plant.queue_free()
	
func population():
	return plant_pop
	
	
func is_area_crowded(pos: Vector2, radius: float) -> bool:
	for p in plant_pop:
		if p.global_position.distance_to(pos) < radius:
			return true
	return false
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	plant_maximum = Globals.parameters["plant_cap"]
	
	#controls sporadic growth for plants
	time_elapsed += delta
	if time_elapsed >= INTERVAL:
		
		var new_growth = []
		plant_pop.reverse()
		
		#new growth array is used so this loop doesnt run forever until max is hit.
		for plant in plant_pop:
			if (plant_pop.size() + new_growth.size()) < plant_maximum:
				plant.force_multiplication(new_growth, world_rect, self)
				
		#new growth is combined post loop termination	
		plant_pop.append_array(new_growth)
		
		
		
		var left   = world_rect.global_position.x
		var right  = world_rect.global_position.x + world_rect.size.x
		var top    = world_rect.global_position.y
		var bottom = world_rect.global_position.y + world_rect.size.y
		
		#used to help prevent clumping and allow better plant spread
		#call it "background seeding"
		for i in range(3): # tune this
			if plant_pop.size() < plant_maximum:
				var rand_pos = Vector2(
					randf_range(left, right),
					randf_range(top, bottom)
				)
				
				#prevent outta bounds spawning for random spread
				#copied from the force multiplication method
				
				#adjust the lower limit of the clamp margin to make plants grow closer to walls
				var margin = randf_range(50, 120)
				
				rand_pos.x = clamp(rand_pos.x, left + margin, right - margin)
				rand_pos.y = clamp(rand_pos.y, top + margin, bottom - margin)
				spawn_plant(rand_pos, plant_pop)
		
		
		
		time_elapsed = 0.0
	
	
