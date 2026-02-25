extends Node2D
class_name ControlSlider

var control_variable = null
@onready var slider = $Panel2/Panel/HSlider


#initialize the slider with the necessary constants
func build_control_variable(variable, max, min, default):
	control_variable = variable
	slider.min_value = min
	slider.max_value = max
	slider.value = default
	
func set_texture(path):
	$Panel4/Panel3/Sprite2D.texture = load(path)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel4/Panel3/Sprite2D.scale =  Vector2.ONE * 0.05
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_h_slider_value_changed(value: float) -> void:
	#change the variable that this is linked to
	Globals.parameters[control_variable] = int(value)
	
