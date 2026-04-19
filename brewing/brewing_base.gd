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
		"TeaCont1": brewing_dir + "tea_container.gd",
		"TeaPrep": brewing_dir + "tea_prep.gd",
		"ServeTray": brewing_dir + "tea_serve_tray.gd",
		"Burner": brewing_dir + "burner.gd",
	}

	# A lot of items have unique behavior (TeaCup gets duplicated, Kettle timer, etc.) so those are treated as exceptions
	# TODO: Why the fuck don't I do this in each item's _ready() function? Bruh
	# The order of ops is that the brewing base enters the tree, and then we call the ready function
	# on all these items. ggwp
	for item_name in item_to_script:
		var script_path = item_to_script[item_name]
		var item_script = load(script_path)
		# NOTE: This errors atm because TeaCont doesn't exist.
		var item_node = brewing_env.get_node(item_name)
		print("Loading: ", item_name)

		# NOTE: I'd love to move this dupe stuff into the respective ready funcs
		# but not a prio for now
		if item_name == "TeaCup1":
			var cup_node = brewing_env.get_node(item_name)
			# Generate the cup reference
			cup_ref = cup_node.duplicate()
			cup_ref.name = cup_node.name.rstrip("0123456789")
			cup_node.queue_free()

			# Create all the cups
			var cup_x_offset = 1.0
			for i in range(0, 4):
				var new_cup = cup_ref.duplicate()
				new_cup.name = cup_ref.name + str(i)
				new_cup.position = Vector3(cup_ref.position.x+cup_x_offset*i, cup_ref.position.y, cup_ref.position.z)
				new_cup.set_script(item_script)
				add_child(new_cup)

		elif item_name == "TeaCont1":
			# Give all the tea containers the scripts
			for i in range(1, 7):
				var tea_container = brewing_env.get_node("TeaCont" + str(i))
				tea_container.set_script(item_script)
		else:
			item_node.set_script(item_script)

	print("Finished loading brewing base")
	
func change_debug_text(new_text):
	get_node("Character").debug_text_label.text = new_text
