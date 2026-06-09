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

var move_bounds = 0.5
func _physics_process(_delta):
	# TODO: Don't move if collide
	# TODO: Working with tethers or some kind of bounds
	var colliding = false

	# If the camera can't move, don't do anything
	# When we can/should move, check where we are in terms of offset
	# 	If the current_offset is +/- 0.5 within the original_offset, move camera with player
	# 	Otherwise, update the current_offset based on the character movement (to zero)
	if not colliding:
		# If we can't move, start to adjust the offset based on the character's position and original offset
		char_pos = character.global_position
		current_offset = Vector3(global_position.x-char_pos.x, global_position.y-char_pos.y, global_position.z-char_pos.z)
		var diff = current_offset - original_offset.abs()
		if diff.x < move_bounds and diff.z < move_bounds:
			_update_camera() # Hopefully this isn't too jittery when it resets?

func _update_camera():
	print("Updating!")
	# PICKUP HERE
	global_position = Vector3(global_position.x-char_pos.x, global_position.y-char_pos.y, global_position.z-char_pos.z)
