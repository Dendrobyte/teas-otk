extends Node3D
class_name TeaServe

# We use "TeaServe" because "Counter" seems like it might be a reserved variable
# Also "counter" is kind of a naming convention of its own
func interact(player_node):
	var held_item = player_node.held_item
	if held_item == null:
		return "Nothing being held to serve"
	print("Min name: ", player_node.get_held_item_min_name())
	if player_node.get_held_item_min_name() == "TeaCup":
		var res = player_node.check_raycast_collision([held_item.get_node("StaticBody3D")])
		# Offset for cup origin being in middle of cup, but I should change that
		# TODO: Proper placement of snapping things
		held_item.global_position = Vector3(res.position.x, res.position.y + .3, res.position.z)
		held_item.reparent(self)
		player_node.set_held_item(null)
		# TODO: Check for cup.is_steeped() or something
		return "Cup has been served"
	elif player_node.get_held_item_min_name() == "Kettle":
		var kettle = held_item as Kettle
		player_node.set_held_item(null)
		kettle.reset_position()
		return "Kettle has been placed back"
	else:
		return "Unhandled item on serving"
