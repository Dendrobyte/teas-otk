extends CharacterBody3D

@export var speed = 10
# TODO: Do this programatically instead of in the editor? Depends on how I spawn in the scene I guess
@export var dialogue_runner: Node

var target_velocity = Vector3.ZERO
var is_in_dialogue = false

func _ready():
	var camera = $Camera
	var x_rotation = deg_to_rad(-1*GlobalState.ROTATION_ANGLE[GlobalState.GameMode.OVERWORLD])
	camera.global_rotate(Vector3(1.0, 0.0, 0.0), x_rotation)

	# Ensure we can't move when dialogue is started
	# NOTE: Am I going to have to hide the interact button?
	dialogue_runner.dialogue_started.connect(func(): is_in_dialogue = true)
	dialogue_runner.dialogue_completed.connect(func(): is_in_dialogue = false)

func _physics_process(_delta):
	if is_in_dialogue:
		return

	var direction = Vector3.ZERO

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
