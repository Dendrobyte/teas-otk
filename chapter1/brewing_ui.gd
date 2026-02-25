extends Control

var center_x = null
var center_y = null

# For now, just calculates a reticle position
func _ready():
    center_x = size.x / 2
    center_y = size.y / 2

# Draw a circle at the reticle position
func _draw():
    draw_circle(Vector2(center_x, center_y), 9.3905, Color.ALICE_BLUE)
