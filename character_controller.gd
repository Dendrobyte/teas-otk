# extends Node
# class_name CharacterController

# @export var offset_const = .5
# @export var speed = 10
# var target_velocity = Vector3.ZERO
# # I'm unsure how I feel about these being here, but I'm okay with this structure for now
# var is_in_cutscene = false
# var is_in_dialogue = false

# var narrative_controller: NarrativeController
# var character: CharacterBody3D
# func setup(narrative_controller_ref: NarrativeController, character_ref: CharacterBody3D):
# 	narrative_controller = narrative_controller_ref
# 	character = character_ref

# 	var camera = $Camera
# 	var x_rotation = deg_to_rad(-1*GlobalState.ROTATION_ANGLE[GlobalState.GameMode.OVERWORLD])
# 	# Set rotation, in case I've modified it in the editor
# 	camera.set_global_rotation(Vector3(x_rotation, 0.0, 0.0))

# 	var dialogue_controller = narrative_controller.dialogue_controller
# 	# Ensure we can't move when dialogue is started
# 	# NOTE: Am I going to have to hide the interact button?
# 	dialogue_controller.dialogue_runner.dialogue_started.connect(func(): is_in_dialogue = true)
# 	dialogue_controller.dialogue_runner.dialogue_completed.connect(func(): is_in_dialogue = false)

# 	dialogue_controller.cutscene_started.connect(func(): is_in_cutscene = true)
# 	dialogue_controller.cutscene_ended.connect(func(): is_in_cutscene = false)

# 	character_ref.sprite.frame = 1

# var gravity = 8
# func _physics_process(_delta):
# 	print("hi")
# 	# TODO: I can apparently set_process_input(false) and set_physics_process(false)
# 	# to do this on the engine level? But it has to be done on a node, obviously not global
# 	if is_in_dialogue or is_in_cutscene:
# 		return

# 	var direction = Vector3.ZERO

# 	# I don't think I need falling logic yet?
# 	# if not is_on_floor():
# 	# 	target_velocity.y -= gravity * delta

# 	# We want to cast the floor collision ray where they're going, not where they are, to avoid getting stuck
# 	var ray_offset = {
# 		x = 0,
# 		z = 0,
# 	}

# 	# TODO: Support both movements to go diagonally
# 	if Input.is_action_pressed("move_up"):
# 		direction.z -= 1
# 		ray_offset.z = offset_const*-1
# 		character.sprite.frame = 0
# 	if Input.is_action_pressed("move_down"):
# 		direction.z += 1
# 		ray_offset.z = offset_const # Moving "down" is positive in the Z direction, toward the camera
# 		character.sprite.frame = 1
# 	if Input.is_action_pressed("move_right"):
# 		direction.x += 1
# 		ray_offset.x = offset_const
# 		character.sprite.frame = 3
# 	if Input.is_action_pressed("move_left"):
# 		direction.x -= 1
# 		ray_offset.x = offset_const*-1
# 		character.sprite.frame = 2

# 	# Snap y level to ground mesh
# 	var space_state = character.get_world_3d().direct_space_state
# 	var global_position = character.global_position
# 	var ray_start = Vector3(global_position.x+ray_offset.x, global_position.y+5, global_position.z+ray_offset.z) # Start above the player?
# 	var ray_end = Vector3(global_position.x+ray_offset.x, global_position.y-10, global_position.z+ray_offset.z) # I don't think we need to go too far down?
# 	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
# 	query.exclude = [self]
# 	var result = space_state.intersect_ray(query)
# 	# If no result, player is attempting to walk off something
# 	# TODO: Mess with vector length, potentially "float" players down if not high up
# 	if result:
# 		global_position.y = result.position.y

# 	if direction != Vector3.ZERO and result:
# 		direction = direction.normalized()
# 		# TODO: Update the sprite shown here based on direction
# 		target_velocity.x = direction.x * speed
# 		target_velocity.z = direction.z * speed
# 		character.velocity = target_velocity
# 		character.move_and_slide()
