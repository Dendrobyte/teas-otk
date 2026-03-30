extends Node3D

@export var sensitivity: float = 0.002
@export var yaw_limit: float = 60.0   # degrees left/right
@export var pitch_min: float = -30.0  # degrees down
@export var pitch_max: float = 25.0   # degrees up
@export var ray_length = 100

var yaw: float = 0.0
var pitch: float = 0.0

var debug_cyl = null
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

## Temporary order clicking
# Figuring out a proper system for this is TBD, I just want to get a full loop and then come in and redo everything
var next_item_idx = 0
var item_seq = ["Pot", "Burner", "Cup"]

func proceed_to_next(clicked_item_name):
	if next_item_idx == len(item_seq):
		print("You are done!")
	else:
		if clicked_item_name.contains(item_seq[next_item_idx]):
			print("Step completed!")
			next_item_idx += 1
		else:
			print("Wrong step")
## End of that stuff

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
	if event.is_action_pressed("click"):
		## { "position": (-4.876412, 3.20117, 5.886989), "normal": (1.0, 0.0, 0.0), "face_index": -1, "collider_id": 30400316950, "collider": Pot:<StaticBody3D#30400316950>, "shape": 0, "rid": RID(631360192512) }
		var collided_obj = check_raycast_collision()
		if !collided_obj.is_empty():
			# TODO: Ideally the objects themselves only have visual updates, e.g. pot.start_boiling, and everything else handled otherwise
			# 		or through property access, e.g. cup.tea_type
			# TODO: Emit a signal if we update the inventory with this selection or something
			proceed_to_next(collided_obj.collider.name)

func check_raycast_collision():
	var cam = $Camera3D
	var origin = cam.project_ray_origin($Control.cursor_pos)
	var end = origin + cam.project_ray_normal($Control.cursor_pos) * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	return result
