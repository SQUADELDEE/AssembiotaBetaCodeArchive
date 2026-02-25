extends Node2D
class_name SmartCellGrid

@onready var title = $Panel/TitleText
@onready var description = $Panel/DescripText
@onready var member_list = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is BasicOrganelle:
		member_list.append(parent)
		title.text = parent.org_name
		description.text = parent.org_descrip


func _on_area_2d_area_exited(area: Area2D) -> void:
	var parent = area.get_parent()
	
	if parent is BasicOrganelle:
		member_list.erase(parent)
	if len(member_list) == 0:
		title.text = "AWAITING ORGANELLE"
		description.text = "DRAG AN ORGANELLE IN THE TRAY SLOT TO START"
	#for the case that there are multiple organelles in the tray
	else:
		parent = member_list[0]
		title.text = parent.org_name
		description.text = parent.org_descrip
		
			
		
		
	pass # Replace with function body.
