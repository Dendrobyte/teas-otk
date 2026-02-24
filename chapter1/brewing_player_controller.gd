extends Node3D

@export var sensitivity: float = 0.002
@export var yaw_limit: float = 60.0   # degrees left/right
@export var pitch_min: float = -30.0  # degrees down
@export var pitch_max: float = 25.0   # degrees up

var yaw: float = 0.0
var pitch: float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# NOTE: Potential use case for _unhandled_input?
func _input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		yaw = clamp(yaw, deg_to_rad(-yaw_limit), deg_to_rad(yaw_limit))
		pitch = clamp(pitch, deg_to_rad(pitch_min), deg_to_rad(pitch_max))
		rotation = Vector3(pitch, yaw, 0.0)
	if event.is_action_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)