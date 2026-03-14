extends Sprite3D

# TODO: Animations, etc. some day

func _ready():
	var x_rotation = deg_to_rad(-1*GlobalState.ROTATION_ANGLE[GlobalState.GameMode.OVERWORLD])
	global_rotate(Vector3(1.0, 0.0, 0.0), x_rotation)