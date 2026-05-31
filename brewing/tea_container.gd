extends Node3D
class_name TeaContainer

# Map of data of the tea this should hold
var tea_info
var inventory_controller


func _ready():
	# NOTE: I don't love how much I'm doing this group thing
	# Surely there's a way to pass it in on setup... but these reayd up after the inv controller so idk
	var inv_con_group = get_tree().get_nodes_in_group("inventory_controller")
	if inv_con_group.is_empty():
		push_error("NO INVENTORY CONTROLLER FOUND FOR ", self, "!")
	else:
		inventory_controller = inv_con_group[0]

	# Shitty way to get container number, should work fine for now
	# TODO: For post-prototype scope, but worth creating a system for this that represents how we load data
	#		Would want to consider, for example, a player being able to organize the shelf
	var cont_num = int(name.substr(len(name)-1))-1
	tea_info = inventory_controller.setup_tea_container(cont_num)

	# Set up a small display for counter
	var container_label: Label3D = Label3D.new()
	container_label.text = tea_info.type
	add_child(container_label)

	print("Set up container ", cont_num, " to hold ", tea_info.get("type"), " (quant: ", tea_info.get("quantity"), ")")

func interact(player_node):
	if player_node.get_held_item_min_name() not in ["teabag", "TeaCup"]:
		var teabag = player_node.new_teabag()
		teabag.scale = Vector3(teabag.scale.x*.5, teabag.scale.y*.5, teabag.scale.z*.5)
		player_node.set_held_item(teabag)
		return "Teabag picked up"
