extends Control

# STUB: I presume we'll be updating this and iterating over of what to draw
var drawing_data = {}
func _draw():
	# Programmatically draw background
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.15, 0.15, 0.2))
	if current_stroke.size() >= 2:
		draw_polyline(PackedVector2Array(current_stroke), Color.GREEN, 4.0, true)

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
			# TODO: Recognize stroke based on the data into $1
		queue_redraw()
	elif event is InputEventMouseMotion and drawing:
		current_stroke.append(event.position)
		queue_redraw()
