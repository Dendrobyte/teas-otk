extends Node3D

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
			# TODO: Emit a signal if we update the inventory with this selection or something
			trigger_item_interaction(collided_obj.collider)

# Not all of them use the passed in node, but it's good to have
var item_interact_funcs = {
	"TeaInv": shelf_interaction,
	"TeaCup": cup_interaction,
	"TeaServe": counter_interaction, # Something weird with COunter-col blah blah
}

func trigger_item_interaction(item_node_collider):
	var item_node = item_node_collider.get_parent()
	var item_name = item_node.name
	print("Triggering collision for ", item_name)
	var min_name = item_name.rstrip("0123456789")
	# TODO: This passes the collider, so get the parent
	item_interact_funcs[min_name].call(item_node)

## ITEM FUNCTIONS ##
# Some day, maybe adding state to each of these items
# But since I'm not worrying about animations or anything now, we're good

var held_item: Node = null
var held_item_static_body: StaticBody3D = null

var is_holding_cup = false
var is_cup_empty = true
var has_teabag = false
var teabag = null
func shelf_interaction(_tea_inv_node):
	if not has_teabag and not is_holding_cup:
		teabag = teabag_model.instantiate()
		teabag.scale = Vector3(teabag.scale.x*.5, teabag.scale.y*.5, teabag.scale.z*.5)
		add_child(teabag) # TODO: Add to a different child? But I want it to track there... So maybe I do keep it on player?
		set_held_item(teabag)
		has_teabag = true
		teabag.global_position = get_hold_location_pos()
		debug_text_label.text = "Teabag picked up"

# TODO: Place teabag in cup, then pick up cup
func cup_interaction(cup_node):
	if has_teabag:
		teabag.queue_free()
		has_teabag = false
		cup_node.global_position = get_hold_location_pos()
		cup_node.reparent(self)
		set_held_item(cup_node)
		is_holding_cup = true
		debug_text_label.text = "Cup picked up"
		# TODO: Can put cup down somewhere to pour water into

func counter_interaction(counter_node):
	if is_holding_cup:
		var res = check_raycast_collision([held_item.get_node("StaticBody3D")])
		# again, idk position vs global at this point but no questions lol
		# The cup origin is in the center of the cup, so I could change that
		held_item.global_position = Vector3(res.position.x, res.position.y + .3, res.position.z)
		# Manual adjustments until I make a "proper" snap or something
		held_item.reparent(counter_node) # I should parent this in game_scene? Or at least set a reference for serving?
		is_holding_cup = false
		set_held_item(null)
	# TODO: If the cup is not empty "is_steeped" trigger serve() or something?

## Util Functions ##

func check_raycast_collision(exceptions = []):
	print("Exceptions? ", exceptions)
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

func set_held_item(held_item_node):
	if held_item_node != null:
		held_item = held_item_node
		if held_item_node.has_node("StaticBody3D"):
			held_item_static_body = held_item_node.get_node("StaticBody3D")
		else:
			held_item_static_body = null
	else:
		held_item = null
		held_item_static_body = null
