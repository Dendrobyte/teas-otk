extends Node3D
class_name Burner 

func interact(player_node):
	var held_item = player_node.held_item
	if player_node.get_held_item_min_name() == "Kettle":
		var kettle = held_item as Kettle
		player_node.set_held_item(null)
		kettle.reset_position()
		return "Kettle has been placed back on burner"