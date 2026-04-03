extends CharacterBody3D
class_name CharacterController

# NOTE: Why is this in chapter 2 ._. I guess the old chapter 1 was an overworld thing
# I should have a "brewing" and "overworld" folder setup for assets/scripts re-used depending on environment
@export var speed = 10
@export var narrative_controller: NarrativeController
@export var dialogue_runner: Node
@export var offset_const = .5
@export var sprite: Sprite3D

var target_velocity = Vector3.ZERO
var is_in_dialogue = false
var is_in_cutscene = false

var bottom_center = 0 # y value representing bottom of the image

func _ready():
	var camera = $Camera
	var x_rotation = deg_to_rad(-1*GlobalState.ROTATION_ANGLE[GlobalState.GameMode.OVERWORLD])
	# Set rotation, in case I've modified it in the editor
	camera.set_global_rotation(Vector3(x_rotation, 0.0, 0.0))

	sprite.frame = 1
	# Get the "game scene" node (operate from root?)
	# NOTE: This assumes I'm always testing from Main. I don't mind that right now, but worth redoing if it gets in the way
	# It would just need to be a reference- but it'd have to exist on every entity... so either way I have to find it programmatically
	get_parent().get_parent().character_is_loaded(self)

var gravity = 8
func _physics_process(_delta):
	# TODO: I can apparently set_process_input(false) and set_physics_process(false)
	# to do this on the engine level? But it has to be done on a node, obviously not global
	if is_in_dialogue or is_in_cutscene:
		return

	var direction = Vector3.ZERO

	# I don't think I need falling logic yet?
	# if not is_on_floor():
	# 	target_velocity.y -= gravity * delta

	# We want to cast the floor collision ray where they're going, not where they are, to avoid getting stuck
	var ray_offset = {
		x = 0,
		z = 0,
	}

	# TODO: Support both movements to go diagonally
	if Input.is_action_pressed("move_up"):
		direction.z -= 1
		ray_offset.z = offset_const*-1
		sprite.frame = 0
	if Input.is_action_pressed("move_down"):
		direction.z += 1
		ray_offset.z = offset_const # Moving "down" is positive in the Z direction, toward the camera
		sprite.frame = 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
		ray_offset.x = offset_const
		sprite.frame = 3
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
		ray_offset.x = offset_const*-1
		sprite.frame = 2

	# Snap y level to ground mesh
	var space_state = get_world_3d().direct_space_state
	var ray_start = Vector3(global_position.x+ray_offset.x, global_position.y+5, global_position.z+ray_offset.z) # Start above the player?
	var ray_end = Vector3(global_position.x+ray_offset.x, global_position.y-10, global_position.z+ray_offset.z) # I don't think we need to go too far down?
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	# If no result, player is attempting to walk off something
	# TODO: Mess with vector length, potentially "float" players down if not high up
	if result:
		global_position.y = result.position.y

	if direction != Vector3.ZERO and result:
		direction = direction.normalized()
		# TODO: Update the sprite shown here based on direction
		target_velocity.x = direction.x * speed
		target_velocity.z = direction.z * speed
		velocity = target_velocity
		move_and_slide()

# To be triggered externally. This node should have no context of the outside world.
func set_is_in_cutscene(value):
	is_in_cutscene = value

func set_is_in_dialogue(value):
	is_in_dialogue = value
