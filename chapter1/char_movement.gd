extends CharacterBody3D

@export var speed = 5

var target_velocity = Vector3.ZERO

func _physics_process(_delta):
    var direction = Vector3.ZERO

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