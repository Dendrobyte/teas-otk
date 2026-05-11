extends Node3D

var narrative_controller: NarrativeController

var active_customer_controller#: CustomerActions

# Some fields for each brewing scene, this should be configurable with however I do the dialogue
# For example, a later chapter should have more cups / etc.
func _enter_tree():
	GlobalState.set_gamemode(GlobalState.GameMode.BREWING)

	# Modify environment in custom ways
	# TODO: Should create node groups for each one
	# For now, removing original elements and then creating new ones
	# TODO: Iteration for diff elements, now it's done manually to find a pattern
	var brewing_env = get_node("brewing_env")
	# Access via group? Or brewing base can just have an explicit reference set in the editor?
	narrative_controller = get_tree().get_root().get_node("Main").get_node("NarrativeController")

	# Wire up dialogue signals that eventually hit narrative (and thus dialogue) controller
	active_customer_controller = get_node("ActiveCustomer")
	active_customer_controller.char_dialogue_action.connect(trigger_character_dialogue)

	# NOTE: Is... is this ok? This is kinda weird.
	# Active customer emits dialogue start, and then can listen for the dialogue finish
	narrative_controller.dialogue_controller.dialogue_controller_dialogue_finished.connect(active_customer_controller.dialogue_finished)

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

		# NOTE: I'd love to move this dupe stuff into the respective ready funcs
		# but not a prio for now
		if item_name == "TeaCup1":
			var cup_node = brewing_env.get_node(item_name)
			# Generate the cup reference
			var cup_ref = cup_node.duplicate()
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

		# For specific items, wire up signals here
		if item_name == "ServeTray":
			var tea_tray = item_node as TeaServeTray
			tea_tray.tea_served_on_tray.connect(active_customer_controller.trigger_current_customer_served)
		# TODO: Tea serve tray emits tea served signal
		# TODO: with teabag type, etc.

	print("Finished loading brewing base")
	
func change_debug_text(new_text):
	get_node("Character").debug_text_label.text = new_text

# I don't mind this here, but the setup is flawed
# Something better will evolve
func start_minigame():
	get_node("Character").start_minigame()

# To be triggered from NPC serving, etc.
# We toggle the served variable which will change what dialogue we get from yarnspinner
func trigger_character_dialogue(character_name, is_served):
	# TODO: (Way later) Pass along if it's the correct tea or something too. Perhaps just the type here
	# and we can check it here in the brewing_base depending on how we load the character info
	# Revisit
	# Also, there could be incorrect tea but we still need to know the type?
	print(narrative_controller.dialogue_controller.dialogue_runner.variable_storage.get_value("$is_served"))
	narrative_controller.dialogue_controller.dialogue_runner.variable_storage.set_value("$is_served", is_served)
	narrative_controller.dialogue_controller.start_dialogue(GlobalState.CURRENT_SCENE + "_" + character_name)

	# TODO: Modify character controller so you can't move while progressing, and can't click
	# NOTE: Will need to wire up dialogue finished too

#### INPUT FOR DEBUGGING ####
# TODO: Extend the menu UI to "reset cups" or "insta fill cup" etc.
# I can't rely on buttons and creating more buttons
func _input(event):
	# up arrow for now. just triggers respawn, eventually will go down the list
	# TODO: maybe set up a debug flag or whatnot as you test serving a few different characters
	if event.is_action_pressed("brewing_skip"):
		print("Triggering skip")
		active_customer_controller.trigger_next_customer()
	# Just some generic thing, hopefully can be reused idk
	elif event.is_action_pressed("instant_run"):
		var cup_node = get_node("TeaCup2") as TeaCup
		if cup_node == null:
			cup_node = get_node("TeaCup3").duplicate() # obviously, don't use teacup 3 when testing lol
			cup_node.name = "TeaCup2"
			cup_node.position = Vector3(cup_node.position.x + 2, cup_node.position.y, cup_node.position.z)
		cup_node.is_filled = true
		cup_node.has_teabag = true
