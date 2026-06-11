extends Camera3D

@export var character: CharacterController

var original_offset: Vector3
var current_offset: Vector3 = Vector3.ZERO
var char_pos: Vector3

func _ready():
	print("Camera loading")
	# If this is comment out, I'm experimenting :)
	# var x_rotation = deg_to_rad(-1*GlobalState.ROTATION_ANGLE[GlobalState.GameMode.OVERWORLD])
	# # Set rotation, in case I've modified it in the editor
	# camera.set_global_rotation(Vector3(x_rotation, 0.0, 0.0))

	if character == null:
		push_error("No character node is assigned to the camera!")

	# Save offset from the character and use as our "0 position" to always fix toward
	char_pos = character.global_position
	original_offset = Vector3(global_position.x-char_pos.x, global_position.y-char_pos.y, global_position.z-char_pos.z)
	current_offset = original_offset

var move_bounds = 0.5
func _physics_process(_delta):
	# TODO: Working with tethers or some kind of bounds
	char_pos = character.global_position
	var move_to = char_pos + original_offset
	var colliding = _is_going_to_collide(move_to)

	# If the camera can't move, update the offset so when we DO move the camera doesn't get off-center
	# When we can/should move, check where we are in terms of offset
	# 	If the current_offset is +/- 0.5 within the original_offset, move camera with player
	# 	Otherwise, update the current_offset based on the character movement (to zero)
	if colliding:
		current_offset = global_position - char_pos
	else:
		# If we can't move, start to adjust the offset based on the character's position and original offset
		# current_offset = global_position - char_pos
		var diff = current_offset - original_offset.abs()
		if abs(diff.x) < move_bounds and abs(diff.z) < move_bounds:
			_update_camera() # Hopefully this isn't too jittery when it resets?

func _update_camera():
	global_position = Vector3(char_pos.x+current_offset.x, char_pos.y+current_offset.y, char_pos.z+current_offset.z)

func _is_going_to_collide(target):
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, target)
	query.exclude = [character.get_rid()]
	var result = space.intersect_ray(query)
	return not result.is_empty()
