extends CharacterBody3D

# NOTE: Why is this in chapter 2 ._. I guess the old chapter 1 was an overworld thing
# I should have a "brewing" and "overworld" folder setup for assets/scripts re-used depending on environment
@export var speed = 10
# TODO: Do this programatically instead of in the editor? Depends on how I spawn in the scene I guess
@export var dialogue_runner: Node

var target_velocity = Vector3.ZERO
var is_in_dialogue = false

func _ready():
	var camera = $Camera
	var x_rotation = deg_to_rad(-1*GlobalState.ROTATION_ANGLE[GlobalState.GameMode.OVERWORLD])
	# Set rotation, in case I've modified it in the editor
	camera.set_global_rotation(Vector3(x_rotation, 0.0, 0.0))

	# Ensure we can't move when dialogue is started
	# NOTE: Am I going to have to hide the interact button?
	if dialogue_runner != null: # It's not always present, such as when testing overworld stuff
		dialogue_runner.dialogue_started.connect(func(): is_in_dialogue = true)
		dialogue_runner.dialogue_completed.connect(func(): is_in_dialogue = false)

var gravity = 8
func _physics_process(delta):
	if is_in_dialogue:
		return

	var direction = Vector3.ZERO

	if not is_on_floor():
		target_velocity.y -= gravity * delta

	# TODO: Support both movements to go diagonally
	if Input.is_action_pressed("move_up"):
		direction.z -= 1
	if Input.is_action_pressed("move_down"):
		direction.z += 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# TODO: Update the sprite shown here based on direction
		target_velocity.x = direction.x * speed
		target_velocity.z = direction.z * speed
		velocity = target_velocity
		move_and_slide()
