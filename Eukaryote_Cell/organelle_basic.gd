extends Node2D
class_name BasicOrganelle

var draggable = true
var dragging = false
var inside_droppable = false
var drag_offset = Vector2.ZERO
var body_ref

# Idle movement
var velocity = Vector2.ZERO
var speed = 20.0

@onready var area = $Area2D
@onready var collision_shape = $Area2D/CollisionShape2D
var radius: float

var org_name
var org_descrip

var scale_modifier = 1



func build_organelle(nombre, descrip, texture, modifier):
	org_name = nombre
	org_descrip = descrip
	$Sprite2D.texture = load(texture)
	if pulse_tween:
		pulse_tween.kill()
	scale_modifier = modifier
	start_pulse()
	


func _ready() -> void:
	
	start_pulse()
	radius = collision_shape.shape.radius
	velocity = Vector2.RIGHT.rotated(randf() * TAU)
	
	# Force the connection in code to ensure it's active
	if not area.input_event.is_connected(_on_area_2d_input_event):
		area.input_event.connect(_on_area_2d_input_event)

# The specific click trigger
var pulse_tween: Tween # Add this at the top with your variables

func start_pulse():
	if pulse_tween:
		pulse_tween.kill() # Stop any existing pulse
	pulse_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property($Sprite2D, "scale", Vector2(0.105 * scale_modifier, 0.105 * scale_modifier), 0.5)
	pulse_tween.tween_property($Sprite2D, "scale", Vector2(0.1 * scale_modifier, 0.1 * scale_modifier ), 0.5)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not draggable: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = global_position - get_global_mouse_position()
			
			# Visual "Lift": stop pulsing and grow 20%
			if pulse_tween: pulse_tween.kill()
			create_tween().tween_property($Sprite2D, "scale", Vector2(0.2 * scale_modifier, 0.2 * scale_modifier), 0.1)
			
			get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and dragging:
			dragging = false
			# Resume the organic pulse when dropped
			start_pulse()



func _process(delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() + drag_offset
		return

# --- UTILITY / COLLISION ---

func is_circle_inside_polygon(center: Vector2, r: float, polygon: Array) -> bool:
	if not Geometry2D.is_point_in_polygon(center, polygon):
		return false
	for i in range(polygon.size()):
		var a = polygon[i]
		var b = polygon[(i + 1) % polygon.size()]
		var closest = Geometry2D.get_closest_point_to_segment(center, a, b)
		if center.distance_to(closest) < r:
			return false
	return true		

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('droppable'):
		print("enter dropper")
		inside_droppable = true
		body.modulate = Color(Color.REBECCA_PURPLE, 1)
		body_ref = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group('droppable'):
		print("exit dropper")
		inside_droppable = false
		body.modulate = Color(Color.MEDIUM_PURPLE, 1)
