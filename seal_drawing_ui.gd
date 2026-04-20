extends Control

@onready var label = $ResultLabel
@onready var canvas_bounds = Rect2(Vector2.ZERO, size)
var _label_base_text = "Result: "



# STUB: I presume we'll be updating this and iterating over of what to draw
var drawing_data = {}
var result_stroke: PackedVector2Array = [] # for debugging more or less
func _draw():
	# Programmatically draw background
	draw_rect(canvas_bounds, Color(0.15, 0.15, 0.2))
	if current_stroke.size() >= 2:
		draw_polyline(PackedVector2Array(current_stroke), Color.DARK_RED, 16.0, true)
	if result_stroke.size() > 0:
		draw_polyline(result_stroke, Color.INDIAN_RED, 16.0, true)

var current_stroke: Array[Vector2] = []
var drawing: bool = false
func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			drawing = true
			current_stroke = [event.position]
		else:
			drawing = false
			print("Stroke finished with ", current_stroke.size(), " points")
			print(current_stroke)
			result_stroke = identify_symbol()
			# TODO: Return a const of the seal it matches
			label.text = _label_base_text
		queue_redraw()
	elif event is InputEventMouseMotion and drawing and canvas_bounds.has_point(event.position):
		current_stroke.append(event.position)
		queue_redraw()

func identify_symbol():
	return OneDollar.normalize(current_stroke)
