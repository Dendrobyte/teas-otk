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

func _ready():
	print("Loaded cup: ", name)

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
	if is_filled:
		return "Served cup " + name + "!"
	if player_node.get_held_item_name() == "teabag" and not is_filled:
		player_node.held_item.queue_free()
		player_node.set_held_item(self)
		has_teabag = true

		global_position = player_node.get_hold_location_pos()
		reparent(player_node)

		return "Cup picked up, teabag placed inside"
	elif player_node.get_held_item_name() == "Kettle" and not is_filled:
		is_filled = true
		# TODO: Call a decrease_level function from kettle since we have it
		#       imo signal unnecessary (we'd need to wire it up to every cup)
		return "Filled cup!"
