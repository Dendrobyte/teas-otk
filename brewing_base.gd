extends Node3D

# Some fields for each brewing scene, this should be configurable with however I do the dialogue
# For example, a later chapter should have more cups / etc.
var cup_count = 4 # I think ultimately cups should be infinite, e.g. just a dish rack
var cup_pos  # NOTE: Ideally this ends up being done programmatically. Keep models uniform?
var cup_ref = null
func _enter_tree():
	# TODO: I feel like we would switch the gamemode earlier...? Or perhaps we have a loading state and switch it first
	print("Global state: ", GlobalState)
	GlobalState.set_gamemode(GlobalState.GameMode.BREWING)
	# TODO: Load assets

	# Modify environment in custom ways
	# TODO: Should create node groups for each one
	# For now, removing original elements and then creating new ones
	# TODO: Iteration for diff elements
	var brewing_env = get_node("brewing_env")
	var cup = brewing_env.get_node("TeaCup1") # I should add some tag in Blender of my own (e.g. auto_Name)
	cup_ref = cup.duplicate()
	# NOTE: Find a better way to copy all properties. Probably some flag in duplicate()
	cup_ref.name = cup.name.rstrip("0123456789")
	cup_ref.scale = cup.scale
	cup_ref.position = cup.position
	cup.queue_free()

	# Spawn in the items
	# NOTE: Obviously, this is quite manual
	var cup_x_offset = 1.0
	for i in range(0, 4):
		var new_cup = cup_ref.duplicate()
		new_cup.name = cup_ref.name + str(i)
		new_cup.scale = cup_ref.scale
		new_cup.position = Vector3(cup_ref.position.x+cup_x_offset*i, cup_ref.position.y, cup_ref.position.z)
		add_child(new_cup)

	print("Finished loading brewing base")
	
