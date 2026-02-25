extends Node2D

class_name Plant

var plant_scale = 0.035
var parent_scene
var is_target = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector2.ONE * plant_scale
	
	$Sprite2D.texture = load("res://Assembiota_Ecosystem/resources/Untitled_Artwork (11).png")
	_set_parent_scene()
	
	#simple if block to allow plants some visual variation, flipped across a vert line
	if randf() < 0.5:
		$Sprite2D.flip_h = true
	else:
		pass
	

# Pass in the parent (most likely the plantcontroller 
func _set_parent_scene():
	parent_scene = get_parent()

#spawns a new child plant with a set offset from this current one
#change offest values(in paranthesis) to modify the spreading.
func force_multiplication(list: Array, world: ColorRect, parent_scene: PlantController):

	#Updated (this block of code prevents out of bounds plant gen
	var offset = Vector2(
		randf_range(-200, 200),
		randf_range(-200, 200)
	)
	

	var new_pos = global_position + offset
	
	#world bounds
	var left   = world.global_position.x
	var right  = world.global_position.x + world.size.x
	var top    = world.global_position.y
	var bottom = world.global_position.y + world.size.y
	
	#adjust the lower limit of the clamp margin to make plants grow closer to walls
	var margin = randf_range(50, 120)

	#clamp to prevent spreading out of bounds
	new_pos.x = clamp(new_pos.x, left + margin, right - margin)
	new_pos.y = clamp(new_pos.y, top + margin, bottom - margin)
	
	
	#the controller will check if there is space to grow, which prevents clumping
	
	#adjust radius for higher plant quantity
	if not parent_scene.is_area_crowded(new_pos, 80):
		parent_scene.spawn_plant(new_pos, list)
		
		
	#parent_scene.spawn_plant(new_pos, list)
	

#return's plant's global pos
func return_pos() -> Vector2:
	return global_position
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
