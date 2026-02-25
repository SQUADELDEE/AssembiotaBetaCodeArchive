extends Node2D
class_name CellStatusBar

var val = null

@onready var low = load("res://Eukaryote_Cell/resources/Barlow.png")
@onready var maxim = load("res://Eukaryote_Cell/resources/BarMax.png")
@onready var almost = load("res://Eukaryote_Cell/resources/BarAlmost.png")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func assign_val(texture):
	#icon is a sprite2D
	$Icon.texture = load(texture)
	
func assign_variable(value, tooltip):
	val = value
	$Control.tooltip_text = tooltip
	

func control_health_bar():
	if val == null: 
		return
	
	if val == 0:
		$HP.texture = low
	if val >= 2:
		$HP.texture = maxim
	if val == 1:
		$HP.texture = almost
	
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	control_health_bar()
	pass
