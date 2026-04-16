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

	# Modify environment in custom ways
	# TODO: Should create node groups for each one
	# For now, removing original elements and then creating new ones
	# TODO: Iteration for diff elements, now it's done manually to find a pattern
	var brewing_env = get_node("brewing_env")

	# Programmatically load nodes and attach their scripts via map ref
	# The keys are the names from Blender, the value is the script path to attach and special behavior
	var brewing_dir = "res://brewing/"
	var item_to_script = {
		"TeaCup1": brewing_dir + "teacup.gd",
		"Kettle": brewing_dir + "kettle.gd",
		"TeaInv": brewing_dir + "tea_inv.gd",
		"TeaServe": brewing_dir + "tea_serve.gd",
		"ServeTray": brewing_dir + "tea_serve_tray.gd",
		"Burner": brewing_dir + "burner.gd",
	}

	# TODO: We should treat teacup and teainv the same ultimately... but the placement shifts anyway
	# It's NOT a concern for the prototype, but see if that pattern evolves
	# Just for now, we're using their names to do unique behavior, but I don't generally like that
	for item_name in item_to_script:
		var script_path = item_to_script[item_name]
		var item_script = load(script_path)
		print("Loading: ", item_name)

		if item_name == "TeaCup1":
			var cup_node = brewing_env.get_node(item_name)
			# Generate the cup reference
			cup_ref = cup_node.duplicate()
			cup_ref.name = cup_node.name.rstrip("0123456789")
			cup_ref.get_node("Teabag").hide()
			cup_ref.get_node("Water").hide()
			cup_node.queue_free()

			# Create all the cups
			var cup_x_offset = 1.0
			for i in range(0, 4):
				var new_cup = cup_ref.duplicate()
				new_cup.name = cup_ref.name + str(i)
				new_cup.position = Vector3(cup_ref.position.x+cup_x_offset*i, cup_ref.position.y, cup_ref.position.z)
				new_cup.set_script(item_script)
				add_child(new_cup)
		elif item_name == "TeaInv":
			# Give all the tea containers the scripts
			for i in range(1, 7):
				var tea_inv = brewing_env.get_node("TeaInv" + str(i))
				tea_inv.set_script(item_script)
		else:
			var item_node = brewing_env.get_node(item_name)
			item_node.set_script(item_script)

	print("Finished loading brewing base")
	
