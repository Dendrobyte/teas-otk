extends Control

@onready var label = $ResultLabel
@onready var canvas_bounds = Rect2(Vector2.ZERO, size)
var _label_base_text = "Result: "

# STUB: I presume we'll be updating this and iterating over of what to draw
var drawing_data = {}
var result_stroke: PackedVector2Array = [] # for debugging more or less
var actual_seal: String = "" # also for debugging
var result_seal = null
func _draw():
	# Programmatically draw background
	draw_rect(canvas_bounds, Color(0.15, 0.15, 0.2))
	if current_stroke.size() >= 2:
		draw_polyline(PackedVector2Array(current_stroke), Color.FOREST_GREEN, 16.0, true)

	# DEBUG DRAWS
	if result_stroke.size() > 0:
		var display_points: PackedVector2Array = []
		var center = size / 2
		for point in result_stroke:
			display_points.append(point + center)
		draw_polyline(display_points, Color.DIM_GRAY, 8.0, true)
	if actual_seal != "":
		draw_polyline(SealTemplates.ALL_SEALS[actual_seal], Color.SLATE_BLUE, 8.0, true)

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
			result_seal = identify_symbol() # { "name": ..., "confidence": ... }
			# TODO: Return a const of the seal it matches
			label.text = _label_base_text + result_seal.name + " (" + str(snapped(result_seal.confidence, 0.01)) + ")"
		queue_redraw()
	elif event is InputEventMouseMotion and drawing and canvas_bounds.has_point(event.position):
		current_stroke.append(event.position)
		queue_redraw()

# NOTE: Yes I know I can modify the result_seal variable. No I don't want to.
func identify_symbol():
	var normalized_points = OneDollar.normalize(current_stroke)
	result_stroke = normalized_points # DEBUG LINE
	var recognized_seal = OneDollar.recognize(normalized_points)
	actual_seal = recognized_seal.name # DEBUG LINE
	return recognized_seal
