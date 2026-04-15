extends Node3D
class_name TeaServe

var snapping_points = []
var next_snap_point = 0
func _ready():
	var center = position 
	var start_x = center.x - 3
	for i in range(0, 4):
		snapping_points.append(Vector3(start_x + i, center.y+.4, center.z))

# We use "TeaServe" because "Counter" seems like it might be a reserved variable
# Also "counter" is kind of a naming convention of its own
func interact(player_node):
	var held_item = player_node.held_item
	if held_item == null:
		return "Nothing being held to prepare"
	print("Min name: ", player_node.get_held_item_min_name())
	if player_node.get_held_item_min_name() == "TeaCup":
		# Offset for cup origin being in middle of cup, but I should change that
		# TODO: Proper placement of snapping things
		var cup_node = held_item as TeaCup
		# var res = player_node.check_raycast_collision([held_item.get_node("StaticBody3D")])
		# cup_node.place(res.position)
		# cup_node.place(snapping_points[0])
		cup_node.place(snapping_points[next_snap_point])
		next_snap_point += 1
		cup_node.reparent(self)
		player_node.set_held_item(null)
		return "Cup placed on prep area"
	elif player_node.get_held_item_min_name() == "Kettle":
		var kettle = held_item as Kettle
		player_node.set_held_item(null)
		kettle.reset_position()
		return "Kettle has been placed back"
	else:
		return "Unhandled item on " + name
