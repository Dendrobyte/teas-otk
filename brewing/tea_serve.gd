extends Node3D
class_name TeaServe

@export var total_snap_points = 5
var snapping_points = [] # Treated as a stack!
func _ready():
	var center = position 
	var start_x = center.x - 3
	# TODO: Reverse since we're using a stack
	for i in range(0, total_snap_points):
		snapping_points.push_back(Vector3(start_x + i, center.y+.4, center.z))

# We use "TeaServe" because "Counter" seems like it might be a reserved variable
# Also "counter" is kind of a naming convention of its own
func interact(player_node):
	var held_item = player_node.held_item
	if held_item == null:
		return "Nothing being held to prepare"
	if player_node.get_held_item_min_name() == "TeaCup":
		var cup_node = held_item as TeaCup
		var was_placed = snap_cup_placement(cup_node)
		if was_placed:
			cup_node.tea_serve_ref = self
			cup_node.reparent(self)
			player_node.set_held_item(null)
			return "Cup placed on prep area"
		else:
			# TODO: Some trash icon or to get rid of a cup.
			# This state should never be reachable due to preventing a cup from being picked up.
			# Which I don't prevent right now but it's not important
			return "No available spots for cup to be placed!"
	elif player_node.get_held_item_min_name() == "Kettle":
		var kettle = held_item as Kettle
		player_node.set_held_item(null)
		kettle.reset_position()
		return "Kettle has been placed back"
	else:
		return "Unhandled item on " + name

var cup_to_snap_point = {}
# Returns true/false depending on if it can be placed or not
func snap_cup_placement(cup_node):
	if is_max_capacity():
		return false
	var snap_point = snapping_points.pop_back()
	cup_node.place(snap_point)
	cup_to_snap_point[cup_node.name] = snap_point
	return true

func free_snap_point(cup_name):
	snapping_points.push_back(cup_to_snap_point[cup_name])
	cup_to_snap_point.erase(cup_name)

func is_max_capacity():
	return snapping_points.size() <= 0

	