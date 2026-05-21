extends Control
class_name SealDrawingUI

@onready var label = $ResultLabel
# For now, debugging
# TODO: We can eventually show a user available seals and their images like constellations / guardian signs
@onready var seal_menu = $MenuButton
@onready var clear_button = $ClearButton
@onready var canvas_bounds = Rect2(Vector2.ZERO, size)
var _label_base_text = "Result: "
var all_seals = SealTemplates.ALL_SEALS

signal seal_complete
signal seal_drawing_exit

func _ready():
	var seal_popup = seal_menu.get_popup()
	# This override is one of the few things I'd want to do in the editor, but the popup menu is internal lmao
	seal_popup.add_theme_font_size_override("font_size", 32)

	for seal_name in all_seals:	
		seal_popup.add_item(seal_name)

	seal_popup.id_pressed.connect(_show_symbol)

	clear_button.pressed.connect(_clear_canvas)
	hide()

# STUB: I presume we'll be updating this and iterating over of what to draw
var drawing_data = {}
var current_stroke: Array[Vector2] = []
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

var drawing: bool = false
var can_draw: bool = false
func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# Initial "release" of mouse to activate any of this
		if not event.pressed and not drawing:
			can_draw = true
		if can_draw:
			if event.pressed:
				drawing = true
				current_stroke = [event.position]
			elif not event.pressed and drawing: # The "unpress" event fires when it opens accidentally, causing issues
				drawing = false
				result_seal = identify_symbol() # { "name": ..., "confidence": ... }

				# If they just click once it's nil, let's have them actually give it a shot
				if result_seal != null:
					# This label is more or less just for debugging? Can we make it show up in the editor?
					# label.text = _label_base_text + result_seal.name + " (" + str(snapped(result_seal.confidence, 0.01)) + ")"

					# TODO: Some animation upon success. Move recognition into here
					# TODO: Only emit if it matches a certain %
					#		And we'll have some feedback to let the person know it's not enough or anything too
					# See note above brewing_base.gd:_seal_drawing_complete
					seal_complete.emit(result_seal.name)
				_clear_canvas()

			queue_redraw()
	elif event is InputEventMouseMotion and drawing and canvas_bounds.has_point(event.position):
		current_stroke.append(event.position)
		queue_redraw()

func _input(event):
	if event.is_action_pressed("escape"):
		# We'll also do this if the exit/back button is pressed...?
		_clear_canvas()
		close_window()
		# Either this or the character has a ref to this, but signals feel more expandable
		seal_drawing_exit.emit()

# NOTE: Yes I know I can modify the result_seal variable. No I don't want to.
func identify_symbol():
	var normalized_points = OneDollar.normalize(current_stroke)
	# result_stroke = normalized_points # DEBUGGING PURPOSES
	var recognized_seal = OneDollar.recognize(normalized_points)
	return recognized_seal

# Helpers for show/hide outside of this node
func start_new():
	show()

func close_window():
	can_draw = false
	_clear_canvas()
	hide()

func _clear_canvas():
	drawing_data = {}
	current_stroke = []
	result_stroke = []
	result_seal = null
	actual_seal = ""

func _show_symbol(menu_idx):
	var menu_label = seal_menu.get_popup().get_item_text(menu_idx)
	actual_seal = menu_label
	queue_redraw()
