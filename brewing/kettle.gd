extends Node3D
class_name Kettle

var kettle_parent: Node3D = null
var kettle_origin_position = null # TODO: Change to a transform that holds rotation too?
var timer = null

var is_boiling = false
var is_boiled = false
var water_level = 0

func _ready():
	kettle_parent = get_parent()
	kettle_origin_position = position
	kettle_notready()
	# TOOD: Might need to reset timer based on water_level, etc. Not important rn though.
	timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	timer.timeout.connect(_on_kettle_timer_done)
	add_child(timer)
	var mesh = $KettleLight
	for i in mesh.mesh.get_surface_count():
		var mat = mesh.mesh.surface_get_material(i)
		print(mat)
	
	

# Pointless, but I like it for right now
# Just updates the debug text with current kettle time
# IF i keep the text, add an ew one to show other actions, but i'll
# get rid of the text so idc right now
func _process(_delta):
	if timer.time_left != 0:
		var brewing_base = get_parent().get_parent()
		brewing_base.change_debug_text("Kettle time remaining: " + str(snapped(timer.time_left, .1)) + " seconds")

func interact(player_node):
	if player_node.held_item == null and not is_boiled and not is_boiling:
		is_boiling = true
		timer.start()
		return "Kettle interact to boil has triggered"
	elif player_node.held_item == null and is_boiled:
		player_node.set_held_item(self)
		reparent(player_node)
		return "Picked up the kettle!"
	else:
		return "Unhandled kettle interaction"

func reset_position():
	reparent(kettle_parent)
	position = kettle_origin_position

func _on_kettle_timer_done():
	is_boiled = true
	kettle_ready()
	# For debugging. I don't love the direction this is going but I"ll get rid of the text
	# completely anyway at some point
	var brewing_base = get_parent().get_parent()
	brewing_base.change_debug_text("Kettle boiled!")

func kettle_ready():
	$KettleLight.rotation = Vector3.ZERO

func kettle_notready():
	$KettleLight.rotation = Vector3($KettleLight.rotation.x, $KettleLight.rotation.y, $KettleLight.rotation.z + deg_2_rad(180))
	print("New rotation: ", $KettleLight.rotation)
