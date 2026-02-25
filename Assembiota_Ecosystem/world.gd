extends Node2D

#used to hold the critter population at any given time
var population = []
var predator_population = []
#for now, carrying cap is set to a constant value. Prevents critters from
#with energy dynamics, this is set to a layout reasonable number
var carrying_capacity = INF
#counter that increments in order 
var time_elapsed: float = 0.0
#using this to control the simulation's time interval
const INTERVAL: float = 2.0 
var rng = RandomNumberGenerator.new()


@export var fish_scene: PackedScene = preload("res://Assembiota_Ecosystem/critter.tscn")
@export var fish_count: int = 15

var plant_gen_ref: PackedScene = preload("res://Assembiota_Ecosystem/plant_controller.tscn")
#plantcontroller instance
var plant_gen

#flying predator variables:
@export var flying_pred_scene: PackedScene = preload("res://Assembiota_Ecosystem/flying_predator.tscn")
@onready var predator_container = $PredatorContainer

@onready var tank_bounds = $TankBounds
@onready var fish_container = $CritterContainer



func _on_button_pressed() -> void:
	_spawn_flying_predator()
	
	



func _ready():
	
	
	#initialize the generator to make plants 
	plant_gen = plant_gen_ref.instantiate()
	add_child(plant_gen)
	#this line is important and makes sure the controller is aware of the world
	plant_gen._intialize_world(tank_bounds)
	#make sure plants always gen under creatures
	plant_gen.z_index = 5
	
	population = []
	predator_population = []
	
	
	
	#spawn some critters to start off the population
	_spawn_critter()
	_spawn_critter()
	_spawn_critter()
	_spawn_critter()
	
	
	print("start population is: " + str(population.size()))
	
	#testing sliders
	$CanvasLayer/ControlSlider.build_control_variable("plant_cap", 250, 0, 150)
	$CanvasLayer/ControlSlider.set_texture("res://Assembiota_Ecosystem/resources/Untitled_Artwork (11).png")
	
#function that assists with creating fresh critters. Adds them to both the 
#population list (logical) and the scene tree (graphical)

#critters are not required to have parents
func _spawn_critter(parent1 = null, parent2 = null, is_child = false, pos = Vector2(500, 500)):
	if is_child:
		var rect := Rect2(
			tank_bounds.position,
			tank_bounds.size
		)
		var fish = fish_scene.instantiate()
		
		fish.position = pos
		fish.set_tank_rect(rect)
		fish_container.add_child(fish)
		population.append(fish)
		#apply mutations if we've got parents
		fish.build_mutations_from_parents(parent1, parent2)
		#creatures always above plants
		fish.z_index = 10
	else:
		
		randomize()
		var rect := Rect2(
			tank_bounds.position,
			tank_bounds.size
		)
		var fish = fish_scene.instantiate()
		fish.position = Vector2(
			randf_range(rect.position.x, rect.position.x + rect.size.x),
			randf_range(rect.position.y, rect.position.y + rect.size.y)
		)
		fish.set_tank_rect(rect)
		fish_container.add_child(fish)
		population.append(fish)
		#creatures always above plants
		fish.z_index = 10
		
		
func _spawn_flying_predator(is_child = false, pos = Vector2(500, 500)):
	if is_child:
		var rect := Rect2(
			tank_bounds.position,
			tank_bounds.size
		)
		var predator = flying_pred_scene.instantiate()
		predator.position = pos
		predator.set_tank_rect(rect)
		predator_container.add_child(predator)
		predator_population.append(predator)
		#flying predators at the topmost level
		predator.z_index = 20
	else:
		
		randomize()
		var rect := Rect2(
			tank_bounds.position,
			tank_bounds.size
		)
		var predator = flying_pred_scene.instantiate()
		predator.position = Vector2(
			randf_range(rect.position.x, rect.position.x + rect.size.x),
			randf_range(rect.position.y, rect.position.y + rect.size.y)
		)
		predator.set_tank_rect(rect)
		predator_container.add_child(predator)
		predator_population.append(predator)
		#flying predators at the topmost level
		predator.z_index = 20


	
	
func _process(delta: float) -> void:
	
	#testing-----
	if population and predator_population:
		for predator in predator_population:
			#not a good targeting system, make sure to update
			predator.swoop_for_prey(predator.target_critter(population), delta, population, fish_container)
	
	
	#food handling (beta)
	#only eat when a plant is untarget by another creature and there are plants available
	for critter in population:
		if critter.check_eat() == true and plant_gen.population():
			critter.target_and_eat_closest_plant(plant_gen)
			#for planta in plant_gen.population():
				#if planta.is_target == false:
					#planta.is_target = true
					##set to false to prevent insane continous targeting
					#critter.is_eat = false
					#critter.eat_plant(plant_gen, planta)
					#break		
	
	#kill off critters who are starving

	
	#using this timer to model increasing population over carrying capacity
	time_elapsed += delta
	if time_elapsed >= INTERVAL:
		
		var mate_dict = {}
		
		#age first
		for critter in population:
			critter._increase_age(1)
			
		
		#killing has been re-enabled
			
		var critters_to_remove = []
		for critter in population:
			if critter.energy <= 0 or critter._is_time_to_die():
				critters_to_remove.append(critter)
			

		for item in critters_to_remove:
			print(str(item) + " died")
			#handle death including animations, removal, etc.
			item.do_death_sequence(population, fish_container)
			
			#fish_container.remove_child(item)
			#population.erase(item)
			##this line is essential for proper critter removal
			#item.die()
			
		print("current population post aging event is: " + str(population.size()))
		
		
		#find mates
		for critter in population:		
			if critter._is_permitted_to_reproduce() and (critter._has_mate() == false):
				for critter2 in population:
					if critter2._is_permitted_to_reproduce() and (critter2._has_mate() == false) and critter != critter2:
						mate_dict[critter] = critter2
						critter2._set_mated(true)
						critter._set_mated(true)
						print("mate found")
						break
		
		var pos_array = mate_dict.keys()
		for i in range(mate_dict.size()):
			var parent = pos_array[i]
			var parent2 = mate_dict[pos_array[i]]
			
			#children will take in mom and dad's mutations
			_spawn_critter(parent, parent2, true, parent.return_global_pos())
			
		
	
		for critter in population:
			#prepare for mating next season!
			critter._set_mated(false)
				
		if population.size() == carrying_capacity:
			print("carrying capacity reached")
		 
		
		
		
		print("current population is: " + str(population.size()))
		time_elapsed = 0.0
	


	



	


func _on_button_2_pressed() -> void:
	_spawn_critter()
	_spawn_critter()
	 # Replace with function body.


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Eukaryote_Cell/CellBase.tscn")
	pass # Replace with function body.
