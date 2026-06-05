extends Node3D
class_name TeaContainer

# Map of data of the tea this should hold
var cont_num
var tea_info:
	set(value):
		tea_info = value
		if tea_info.quantity == 0:
			$ContainerInside.hide()

var inventory_controller
var container_label: Label3D
var label_font: FontFile = preload("res://assets/ui/Leander.ttf")


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
	cont_num = int(name.substr(len(name)-1))-1
	tea_info = inventory_controller.setup_tea_container(cont_num)

	# Set up a small display for counter
	_create_text_label()
	_refresh_text()

func interact(player_node):
	if player_node.get_held_item_min_name() not in ["teabag", "TeaCup"]:
		var try_get_teabag = inventory_controller.get_teabag(cont_num)
		if try_get_teabag == null:
			return "No tea in container!"

		tea_info = try_get_teabag
		_refresh_text()
		
		var teabag: Teabag = inventory_controller.new_teabag(tea_info.type)
		teabag.scale = Vector3(teabag.scale.x*.5, teabag.scale.y*.5, teabag.scale.z*.5)
		player_node.set_held_item(teabag)
		return "Teabag picked up"

func _create_text_label():
	container_label = Label3D.new()
	# Properties taken from modifying in engine
	container_label.position = Vector3(-1.595, .8, -.147)
	container_label.rotation_degrees = Vector3(-42.8, -92.7,  2.3)
	container_label.font = label_font
	container_label.font_size = 64
	add_child(container_label)

func _refresh_text():
	var tea_type_str = inventory_controller.get_type_str(tea_info.type)
	container_label.text = tea_type_str + "\n" + "Amount: " + str(tea_info.quantity)
