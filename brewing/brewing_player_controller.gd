extends Node3D
class_name BrewingPlayer

@export var sensitivity: float = 0.002
@export var yaw_limit: float = 60.0   # degrees left/right
@export var pitch_min: float = -30.0  # degrees down
@export var pitch_max: float = 25.0   # degrees up
@export var ray_length = 40
@onready var debug_text_label = $Control/DebugText

# Assets to preload
@onready var teabag_model = preload("res://assets/models/teabag.glb")

# Camera & character movement
@onready var cam = $Camera3D
var yaw: float = 0.0
var pitch: float = 0.0

# Some text as a temporary visual indicator of where I am and what's updating where
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	debug_text_label.text = "Entered scene"

# NOTE: Potential use case for _unhandled_input?
func _input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		yaw = clamp(yaw, deg_to_rad(-yaw_limit), deg_to_rad(yaw_limit))
		pitch = clamp(pitch, deg_to_rad(pitch_min), deg_to_rad(pitch_max))
		rotation = Vector3(pitch, yaw, 0.0)
	if event.is_action_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("click"):
		# NOTE: Just the structure of this item
		## { "position": (-4.876412, 3.20117, 5.886989), "normal": (1.0, 0.0, 0.0), "face_index": -1, "collider_id": 30400316950, "collider": Pot:<StaticBody3D#30400316950>, "shape": 0, "rid": RID(631360192512) }
		var collided_obj = check_raycast_collision() if not held_item_static_body else check_raycast_collision([held_item_static_body])
		if !collided_obj.is_empty():
			# TODO: Ideally the objects themselves only have visual updates, e.g. pot.start_boiling, and everything else handled otherwise
			# 		or through property access, e.g. cup.tea_type
			# TODO: Emit a signal to game_scene if we update the inventory with this selection or something
			# If there's an interact function, call it
			var item_node = collided_obj.collider.get_parent()
			if item_node.has_method("interact"):
				# NOTE: We're returning a string right now to set debug text
				# Idt we need to actually return anything so... it's aight
				debug_text_label.text = item_node.interact(self)

## Item Handling Stuff ##

var held_item: Node = null
var held_item_static_body: StaticBody3D = null

# NOTE: Having this in player controller isn't a problem imo. It's just for when they hold it.
# Just used when picking up teabag atm, and set to held item inside of tea_inv. Could change?
func new_teabag():
	return teabag_model.instantiate()

func check_raycast_collision(exceptions = []):
	var origin = cam.project_ray_origin($Control.cursor_pos)
	var end = origin + cam.project_ray_normal($Control.cursor_pos) * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = exceptions
	query.collide_with_areas = true

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	return result

# We'll constantly use the ray approach to put an item at a position in front of the player
func get_hold_location_pos():
	var origin = cam.project_ray_origin($Control.cursor_pos)
	var end = origin + cam.project_ray_normal($Control.cursor_pos) * 4
	return end

# TODO: Can't I make this a generic set() below the variable that runs?
#		Just need to replace all instances
func set_held_item(held_item_node):
	if held_item_node != null:
		held_item = held_item_node
		if held_item.get_parent() == null:
			add_child(held_item)
		else:
			held_item.reparent(self)
		held_item_node.global_position = get_hold_location_pos()
		if held_item_node.has_node("StaticBody3D"):
			held_item_static_body = held_item_node.get_node("StaticBody3D")
		else:
			held_item_static_body = null
	else:
		held_item = null
		held_item_static_body = null

# This exists to avoid a bunch of null checks when we get the name
func get_held_item_name():
	if held_item != null:
		return held_item.name
	else:
		return "NULL"

func get_held_item_min_name():
	return get_held_item_name().rstrip("0123456789")
