extends Node3D
class_name TeaCup

@export var is_filled: bool = false:
	set(value):
		is_filled = value
		if is_node_ready(): toggle_water(value)

@export var has_teabag: bool = false:
	set(value):
		has_teabag = value
		if is_node_ready(): toggle_teabag(value)

@export var seal_drawn: bool = false

@onready var brewing_base = get_parent()

# We'll store references that can effectively be used as boolean checks as well, versus traversing for the node?
var tray_ref: TeaServeTray = null
var tea_prep_ref: TeaPrep = null
var particles: GPUParticles3D = null
var teacup_particle_scene = preload("res://brewing/particles_teacup.tscn")

func _ready():
	$Water.hide()
	$Teabag.hide()
	particles = teacup_particle_scene.instantiate()
	particles.emitting = false
	add_child(particles)

func toggle_water(value):
	if value:
		$Water.show()
	else:
		$Water.hide()

func toggle_teabag(value):
	if value:
		$Teabag.show()
	else:
		$Teabag.hide()

func interact(player_node):
	# This check is for triggering plant seal, I don't really like it though
	# I just don't want someone to have to click twice
	var was_missing_one_req = not (is_filled and has_teabag)

	if player_node.held_item == null:
		if is_filled and has_teabag and not seal_drawn:
			brewing_base.show_seal_ui("PLANT", _show_aura)
		else: # if seal_drawn == false
			player_node.set_held_item(self) # fourth instance! maybe pickup_item? takes the new parent, but its always player so reparent(player_node)
			if tray_ref != null:
				tray_ref.clear_tray()
				tray_ref = null
			if tea_prep_ref != null:
				tea_prep_ref.free_snap_point(name)
				tea_prep_ref = null
			return "Picked up " + name
	elif player_node.get_held_item_name() == "teabag":
		if not has_teabag:
			if tea_prep_ref != null:
				tea_prep_ref.free_snap_point(name)
				tea_prep_ref = null

			player_node.held_item.queue_free()
			player_node.set_held_item(self) # third instance I'm seeing these two lines I think
			reparent(player_node)
			has_teabag = true
			return "Cup picked up, teabag placed inside"
		else:
			return "Cup already has teabag"
	elif player_node.get_held_item_name() == "Kettle" and not is_filled:
		var kettle = player_node.held_item as Kettle
		is_filled = true
		kettle.show_pour_animation()
		# TODO: Call a decrease_level function from kettle since we have it
		#       imo signal unnecessary (we'd need to wire it up to every cup)
		return "Filled cup!"
	
	# Trigger seal drawing when we fulfill the two requirements
	# NOTE: Naming is kinda backwards
	var is_missing_one = not (is_filled and has_teabag)
	if was_missing_one_req and not is_missing_one:
		brewing_base.show_seal_ui("PLANT", _show_aura)

# TODO: Show aura around cup if plant seal is drawn
func _show_aura():
	seal_drawn = true
	particles.emitting = true

func can_be_served():
	return is_filled and has_teabag

# TODO: Use global_transform?
func place(surface_position):
	global_rotation = Vector3(0, 0, 0)
	global_position = Vector3(surface_position.x, surface_position.y + .3, surface_position.z)
