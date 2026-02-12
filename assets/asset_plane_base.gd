extends Node3D

@export var plane_texture_img: Texture2D = preload("res://assets/asset_plane_default_image.png")

func _ready():
	# Plane dimensions should match the image (our source of truth)
	var img_size = plane_texture_img.get_size()
	var aspect = img_size.x / img_size.y
	
	$PlaneMesh.mesh.size = Vector2(aspect, 1.0)
	
	# Ensure our pivot point is set up as intended, programmatically to verify
	var half_height = $PlaneMesh.mesh.size.y
	$PlaneMesh.position.y = half_height
	rotation_degrees.x = GlobalState.ROTATION_ANGLE
	
	# Load the texture
	var mat = $PlaneMesh.get_surface_override_material(0)
	if not mat:
		mat = StandardMaterial3D.new()
	mat.albedo_texture = plane_texture_img
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	$PlaneMesh.set_surface_override_material(0, mat)
