extends Node2D


#used to control the cells current status
@export var cell_status = {
	"water" : 0,
	"energy": 0,
	"stability" : 0,
	"cleanliness" : 0,
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#to spawn new organelles, first make sure the spawner knows about the organelle domain
	$ButtonStorageUnit.build_organelle_control($OrganelleDomain)
	
	#make unique organelles firs
	$OrganelleDomain/Golgi.build_organelle("Golgi Apparatus", Globals.golgi_text, "res://Eukaryote_Cell/resources/Golgi.png", 1)
	$OrganelleDomain/Mitochondria.build_organelle("Mitochondria", Globals.mito_text, "res://Eukaryote_Cell/resources/Mitochondria.png", 0.8)
	$OrganelleDomain/Mitochondria2.build_organelle("Mitochondria", Globals.mito_text, "res://Eukaryote_Cell/resources/Mitochondria.png", 0.8)

	$OrganelleDomain/Nucleus.build_organelle("Nucleus W/ ER", Globals.nucleus_text, "res://Eukaryote_Cell/resources/Nucleus_w_Rough_ER.png", 1.5)

	$OrganelleDomain/SmoothER.build_organelle("Smooth ER", Globals.smooth_er_text, "res://Eukaryote_Cell/resources/Smooth_ER.png", 1.5)
	
	$OrganelleDomain/Vacuole.build_organelle("Vacuole", Globals.vacuole_text, "res://Eukaryote_Cell/resources/Vacuole.png", 2.5)
	$OrganelleDomain/Vacuole2.build_organelle("Vacuole", Globals.vacuole_text, "res://Eukaryote_Cell/resources/Vacuole.png", 2.5)
	
	#preset positions for the layout.
	$OrganelleDomain/Golgi.global_position = Vector2(592.218, 591.1318)
	$OrganelleDomain/Mitochondria.global_position = Vector2(808.0406, 283.3673)
	$OrganelleDomain/Mitochondria2.global_position = Vector2(759.1909, 485.7142)
	$OrganelleDomain/Nucleus.global_position = Vector2(341.5964, 382.0483)
	$OrganelleDomain/SmoothER.global_position = Vector2(475.1376, 315.9963)
	$OrganelleDomain/Vacuole.global_position = Vector2(602.048, 234.0891)
	$OrganelleDomain/Vacuole2.global_position = Vector2(406.8446, 614.4731)

	
	
	#make the bars next
	$ControlBar.assign_val("res://Eukaryote_Cell/resources/Control!.png")
	$WaterBar.assign_val("res://Eukaryote_Cell/resources/Waterstorage.png")
	$EnergyBar.assign_val("res://Eukaryote_Cell/resources/Energy.png")
	$TransportBar.assign_val("res://Eukaryote_Cell/resources/TransportResourceManagement.png" )
	
	
func _identify_cell_members():
	var water_need = 0
	var energy_need = 0
	var stability_need = 0
	var cleanliness_need = 0
	
	
	var list_o_bodies = $Area2D.get_overlapping_areas()
	for item in list_o_bodies:
		var organelle = item.get_parent()
		if organelle.org_name == "Golgi Apparatus":
			cleanliness_need += 1
		if organelle.org_name == "Mitochondria" :
			energy_need += 1
		if organelle.org_name == "Nucleus W/ ER":
			stability_need += 2
		if organelle.org_name == "Smooth ER":
			cleanliness_need += 1
		if organelle.org_name == "Vacuole":
			water_need += 1
	
	#init proper dictionary values based on how many of each organelle we have
	cell_status["water"] = water_need
	cell_status["energy"] = energy_need
	cell_status["stability"] = stability_need
	cell_status["cleanliness"] = cleanliness_need
	

	
func report_cell_status():

	
	if cell_status["water"] < 1:
		print("needs water")
	if cell_status["energy"] < 1:
		print("needs energy")
	if cell_status["stability"] < 1:
		print("needs support")
	if cell_status["cleanliness"] < 2:
		print("needs cleaning!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_identify_cell_members()
	
	#report_cell_status()
	#
	$ControlBar.assign_variable(cell_status["stability"], "Control level concerns organelles that tell the cell what to do!")
	$WaterBar.assign_variable(cell_status["water"], "Water and nutrients for the cell!")
	$EnergyBar.assign_variable(cell_status["energy"], "Energy levels for the cell!")
	$TransportBar.assign_variable(cell_status["cleanliness"], "Transport is linked to organelles that move things around!")
	

	
	

#for the trash can
	


func _on_garbage_area_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is BasicOrganelle:
		$OrganelleDomain.remove_child(parent)
		parent.queue_free()


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assembiota_Ecosystem/world.tscn")
	pass # Replace with function body.
