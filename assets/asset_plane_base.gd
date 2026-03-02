extends Node3D

@export var plane_texture_img: Texture2D
@export var scale_factor: int = 2

func _ready():
	# TODO: If plane texture image is nil, check for the parent's plane texture image (e.g. in an NPC)
	# This may also become a default situation, such as when something is a collectable plant or not, etc.
	# Plane dimensions should match the image (our source of truth)
	# Note that w*h ends up as x*z
	var img_size = plane_texture_img.get_size() # This is in pixels, not quite godot units

	# If we say tile size base is 128x128, everything will be a multiple of that
	# and we'll use that to adjust our base ratio
	# TODO: We need to make it so that we can have non-normal images
	# 		Thus, some way to use the aspect ratio yet ensure we don't over scale
	#		(e.g. 1:2 staying as 1:2 while 2:4 stays as 2:4)
	#		So instead of ratio we should just use scale size
	var x_scale = img_size.x / GlobalState.BASE_TILE_SIZE
	var y_scale = img_size.y / GlobalState.BASE_TILE_SIZE

	# TODO: We'll need to adjust the child collider to match this as well

	# Then we calc the size the mesh should be
	var gcd = _gcd(floori(img_size.x), floori(img_size.y))
	var ratio = [x_scale, y_scale]
	print("Ratio: ", ratio)
	$PlaneMesh.mesh.size = Vector2i(ratio[0]*scale_factor, ratio[1]*scale_factor)
	scale.x = ratio[0]
	scale.z = ratio[1]
	
	# Ensure our pivot point is set up as intended, programmatically to verify
	# TODO: If we're in the brewing phase, set the rotation to full 90
	# var half_height = $PlaneMesh.mesh.size.y
	# TODO: Use this to PROPERLY set the origin point
	# rotation_degrees.x = 90 - GlobalState.ROTATION_ANGLE.get(GlobalState.CURRENT_GAMEMODE, 0)
	global_rotation = Vector3(deg_to_rad(90 - GlobalState.ROTATION_ANGLE.get(GlobalState.CURRENT_GAMEMODE, 0)), 0.0, 0.0)
	
	# Load the texture
	# TODO: Redo this setup :)
	var mat = $PlaneMesh.get_surface_override_material(0)
	if not mat:
		mat = StandardMaterial3D.new()
		mat.albedo_texture = plane_texture_img
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	$PlaneMesh.set_surface_override_material(0, mat)

func _gcd(w, h):
	if h == 0:
		return w
	return _gcd(h, w % h)
