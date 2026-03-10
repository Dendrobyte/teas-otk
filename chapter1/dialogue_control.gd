extends Control

#### SCOPE ####
# The dialogue control should ONLY handle:
# 	1. The loading of dialogue per NPC to be displayed with a dialogue box
#	2. Show/hide of interaction button
#	3. It can trigger event updates
# It should contain NONE of the branching flow, etc. Just loading "what's next" for an NPC

# Key is NPC name, value is string
# (for now, we'll figure this system out eventually when I dig into yarnspinner)
var npc_dialogue_map = {}
var interact_button: Sprite3D = Sprite3D.new()
var can_interact = false # I feel like this interaction button thing can become a separate script, if only to modularize it with item gathering
var curr_dialogue = null

## NPC STUFF! / what i want to move out of here
# This is also meant to be moved out like the events at the bottom
var curr_npc = null # merge with above, see note about blob
var old_man: NPCBase = null

## End of NPC stuff

## YarnSpinner setup
# Just hoping that we can have the YarnDialogueRunner as the child of this control and be fine, thus we can create a scene out of the DialogueControl
@onready var dialogue_runner := $YarnDialogueRunner
@onready var line_presenter := $CanvasLayer/LinePresenter
@onready var options_presenter := $CanvasLayer/OptionsPresenter

## End of YarnSpinner setup

# Separate show/hide functions in case I add stuff to show/hide that isn't just the canvas layer
func show_dialogue():
	$CanvasLayer.show()

func hide_dialogue():
	$CanvasLayer.hide()

# General parent dialogue control
# As this grows bigger, move things into child scripts. Otherwise, we can just keep it in here for now
func _ready():
	## YarnSpinner readying setup
	dialogue_runner.add_presenter(line_presenter)
	dialogue_runner.add_presenter(options_presenter)
	# I wish I had elixir lambda here
	dialogue_runner.variable_storage.variable_changed.connect(update_flag)

	# Move to show/hide and dialogue loading
	hide_dialogue()
	connect_to_npc_signals()

	# Set up the interact button
	var interact_texture = ImageTexture.create_from_image(Image.load_from_file("res://assets/ui/keyboard_e.png"))
	interact_button.texture = interact_texture
	interact_button.scale = Vector3(2, 2, 2)
	add_child(interact_button)
	interact_button.hide()

func _input(event):
	# TODO: Freeze all other actions -> look into the unhandled_input flow chart again, I think that may be our answer
	#       We can just "handle" all input here by sinking it into an empty return
	# TODO: If this dialogue triggers an event change (like talking to the old man), reload their dialogue
	if event.is_action_pressed("interact") and can_interact:
		dialogue_runner.start_dialogue(curr_npc)
		show_dialogue()

func connect_to_npc_signals():
	# The NPC parent MUST be on the same level as our dialogue control node
	var npc_parent_node = get_parent().get_node("NPCs")
	for npc_node in npc_parent_node.get_children():
		var npc: NPCBase = npc_node as NPCBase

		npc.npc_collision_enter.connect(_on_character_enters_npc_area)
		npc.npc_collision_leave.connect(_on_character_leaves_npc_area)

		# TODO: Is there a better way to register this kind of thing?
		# How can we move it into the EVENT TRIGGERING block so we can load these unique events in different overworld scenes?
		if npc.name == "OldMan":
			old_man = npc
			old_man.hide() # This doesn't hide the hitbox
	
# When an NPC emits a collision signal on entry, we show the interact button
# TODO: Set the current dialogue... and maybe that cascades into 
func _on_character_enters_npc_area(body: Node3D):
	var npc_name = body.name
	var location = body.global_position
	location.y = location.y + 5
	interact_button.position = location
	interact_button.show()
	can_interact = true
	curr_npc = npc_name

func _on_character_leaves_npc_area(_body: Node3D):
	interact_button.hide()
	can_interact = false
	hide_dialogue()


## EVENT TRIGGERING ##
# I don't like that this is in the dialogue control. It has nothing to do with dialogue. But I think
# we can have some script tracking the events of the "current scene" and then when it changes we update our
# global state. Then we save that global state with all those independent fields
# And somehow each scene will have potential events and such to trigger, as opposed to all of them
# being in one huge file
# UPDATE: I think... this is OK in dialogue control for now actually.
# But what we need to do is, as this evolves into new scenes, load each overworld level individually
# And each overworld level will have its own set of flags, etc. which we load in
# whenever the dialogue control is loaded in
# So everything below here, effectively, will be moved out to a new custom node/script
# Except maybe the update_flag function or anything called from yarn spinner listeners
# That should be the connect YS -> Dialogue Control -> Story State

# Holds on to a flag value and the function to call when it changes
var FLAGS = {
	"checked_for_permit": { # Talk to CitadelGuard
		"value": false,
		"function": on_checked_for_permit,
	},
	"talked_to_old_man": { # Talk to CitadelGuard
		"value": false,
		"function": on_talked_to_old_man,
	}
}

# Connected to the variable_storage variable_changes signal
# TODO: Update some map of flags in this file
func update_flag(var_name, value):
	print("Updating ", var_name, " to ", value)

# All the functions executed on flag change to keep the map somewhat readable
func on_checked_for_permit():
	print("Permit checked!")
	# YarnSpinner flag updates should take it from here, as below
	# TODO: Spawn in the old man

func on_talked_to_old_man():
	print("Talked to old man!")
	# Since our YS flag update function should update the var, I don't think we need to do anything for that
	# TODO: Ensure player can't interact (talk again) to old man, e.g. remove bounding box?

# End of flag execution functions
