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

# func _ready():
# 	print("Loaded cup: ", name)

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
	if player_node.held_item == null:
		player_node.set_held_item(self) # fourth instance! maybe pickup_item? takes the new parent, but its always player so
		reparent(player_node)
		return "Picked up " + name
	elif player_node.get_held_item_name() == "teabag" and not is_filled:
		player_node.held_item.queue_free()
		player_node.set_held_item(self) # third instance I'm seeing these two lines I think
		reparent(player_node)
		has_teabag = true

		return "Cup picked up, teabag placed inside"
	elif player_node.get_held_item_name() == "Kettle" and not is_filled:
		is_filled = true
		# TODO: Call a decrease_level function from kettle since we have it
		#       imo signal unnecessary (we'd need to wire it up to every cup)
		return "Filled cup!"

func can_be_served():
	return is_filled and has_teabag

# TODO: Use global_transform?
func place(surface_position):
	global_rotation = Vector3(0, 0, 0)
	global_position = Vector3(surface_position.x, surface_position.y + .3, surface_position.z)
