extends Control

var cursor_pos = null

# For now, just calculates a reticle position
func _ready():
    cursor_pos = Vector2(size.x / 2, size.y / 2)

# Draw a circle at the reticle position
func _draw():
    draw_circle(Vector2(cursor_pos.x, cursor_pos.y), 9.3905, Color.SEA_GREEN)
