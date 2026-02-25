extends Node2D

@export var organelle_scene: PackedScene = preload("res://Eukaryote_Cell/OrganelleBasic.tscn")


var organelle_control : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func build_organelle_control(control):
	organelle_control = control


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_nucleus_pressed() -> void:
	var new_scene = organelle_scene.instantiate()
	organelle_control.add_child(new_scene)
	new_scene.build_organelle("Nucleus W/ ER", Globals.nucleus_text, "res://Eukaryote_Cell/resources/Nucleus_w_Rough_ER.png", 1.5)
	new_scene.global_position = Vector2(1200, 600)
	pass # Replace with function body.


func _on_vacuole_pressed() -> void:
	var new_scene = organelle_scene.instantiate()
	organelle_control.add_child(new_scene)
	new_scene.build_organelle("Vacuole", Globals.vacuole_text, "res://Eukaryote_Cell/resources/Vacuole.png", 2.5)
	new_scene.global_position = Vector2(1200, 600)
	pass # Replace with function body.



func _on_smooth_er_pressed() -> void:
	var new_scene = organelle_scene.instantiate()
	organelle_control.add_child(new_scene)
	new_scene.build_organelle("Smooth ER", Globals.smooth_er_text, "res://Eukaryote_Cell/resources/Smooth_ER.png", 1.5)
	new_scene.global_position = Vector2(1200, 600)
	pass # Replace with function body.


func _on_golgi_pressed() -> void:
	var new_scene = organelle_scene.instantiate()
	organelle_control.add_child(new_scene)
	new_scene.build_organelle("Golgi Apparatus", Globals.golgi_text, "res://Eukaryote_Cell/resources/Golgi.png", 1)
	new_scene.global_position = Vector2(1200, 600)
	pass # Replace with function body.


func _on_mitochondria_pressed() -> void:
	var new_scene = organelle_scene.instantiate()
	organelle_control.add_child(new_scene)
	new_scene.build_organelle("Mitochondria", Globals.mito_text, "res://Eukaryote_Cell/resources/Mitochondria.png", 0.8)
	new_scene.global_position = Vector2(1200, 600)
	pass # Replace with function body.
