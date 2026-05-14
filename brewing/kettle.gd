extends MeshInstance3D # The import from Blender is this. Needed for transparency shift.
class_name Kettle

var kettle_parent: Node3D = null
var kettle_origin_position = null # TODO: Change to a transform that holds rotation too?
var timer = null

var is_boiling = false
var is_boiled = false
var water_level = 0

var kettle_ready_mat: Material = null
var kettle_not_ready_mat: Material = null

var kettle_wood: Material = null
var kettle_metal: Material = null

func _ready():
	kettle_parent = get_parent()
	kettle_origin_position = position # TODO: Change to transform

	# Programmatically save materials... why not
	# NOTE: I don't really like this. Prob better to import them somehow else, but it works for now
	# Probably doesn't get imported if not assigned- not ready is just hidden
	kettle_not_ready_mat = $KettleLight.get_active_material(0)
	kettle_ready_mat = $KettleLight.get_active_material(1)

	# Set the alpha (variable declared with set_transparent func below)
	kettle_wood = get_active_material(0)
	kettle_metal = get_active_material(1)
	kettle_wood.albedo_color.a = alpha
	kettle_metal.albedo_color.a = alpha

	$KettleLight.set_surface_override_material(1, kettle_not_ready_mat)
	# TODO: Might need to reset timer based on water_level, etc. Not important rn though.
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.timeout.connect(_on_kettle_timer_done)
	add_child(timer)

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
		set_transparent(true)
		return "Picked up the kettle!"
	else:
		return "Unhandled kettle interaction"

func reset_position():
	reparent(kettle_parent)
	position = kettle_origin_position

func _on_kettle_timer_done():
	$KettleLight.set_surface_override_material(1, kettle_ready_mat)
	is_boiled = true
	# For debugging. I don't love the direction this is going but I"ll get rid of the text
	# completely anyway at some point
	var brewing_base = get_parent().get_parent()
	brewing_base.change_debug_text("Kettle boiled!")

# We can just alter the transparency mode
var alpha = 0.3
func set_transparent(val):
	if val:
		kettle_wood.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		kettle_metal.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	else:
		kettle_wood.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		kettle_metal.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
