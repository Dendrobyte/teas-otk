extends Control
#### Transition Window ####
# Treating this like its own thing, why not
# May not need lol, but it could have its own text?

var text = ""
var window_bounds

func _ready():
	window_bounds = Rect2(Vector2.ZERO, size)

func _draw():
	draw_rect(window_bounds, Color(0, 0, 0))
