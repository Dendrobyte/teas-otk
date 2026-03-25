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
var can_interact = false # I feel like this interaction button thing can become a separate script, if only to modularize it with item gathering
var curr_dialogue = null

## NPC STUFF! / what i want to move out of here
## TODO: I also need to move out all the entity stuff.
# This is also meant to be moved out like the events at the bottom
# I think this one can be held onto in the dialogue control, as it indicates whose dialogue we show
var curr_npc = null

# Some map of all NPCs whose behavior we need to tweak
# Should be hard written like the flags end up being
# Every key in here MUST match the node name of NPCs in the Godot Scene
var CUSTOM_NPCS: Dictionary[String, NPCBase] = {
	"OldMan": null,
	"SadGuard": null,
}

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
	dialogue_runner.dialogue_completed.connect(finish_up_dialogue)

	# Entity and environment setup
	connect_to_entity_signals()

	# The interact button lives here I guess... it's technically UI?
	Util.add_interact_button_to_scene(self)

func _input(event):
	# TODO: Freeze all other actions -> look into the unhandled_input flow chart again, I think that may be our answer
	#       We can just "handle" all input here by sinking it into an empty return
	# TODO: If this dialogue triggers an event change (like talking to the old man), reload their dialogue
	if event.is_action_pressed("interact") and can_interact:
		dialogue_runner.start_dialogue(curr_npc)
		show_dialogue()
		Util.interact_button_hide()
		can_interact = false

func connect_to_npc_signals():
	# The NPC parent MUST be on the same level as our dialogue control node
	var npc_parent_node = get_parent().get_node("NPCs")
	for npc_node in npc_parent_node.get_children():
		var npc: NPCBase = npc_node as NPCBase

		npc.npc_collision_enter.connect(_on_character_enters_entity_area)
		npc.npc_collision_leave.connect(_on_character_leaves_entity_area)

		# This is where we grab the custom NPCs from the scene's... uh... entities? node? and then register them in here or something
		if CUSTOM_NPCS.has(npc.name):
			CUSTOM_NPCS[npc.name] = npc

# To connect to bushes, trees, etc.
# It's possible we may generalize this? Do we want this in dialogue control???
func connect_to_entity_signals():
	var entity_parent_node = get_parent().get_node("Environment").get_node("Entities")
	# Current structure is Entities -> ScatterGroup -> Entity1, Entity2, etc.
	# NOTE: May need to rework this?
	for npc_node_group in entity_parent_node.get_children():
		print(npc_node_group)
		for	npc_node in npc_node_group.get_children():
			var entity: EntityBase = npc_node as EntityBase

			entity.entity_collision_enter.connect(_on_character_enters_entity_area)
			entity.entity_collision_leave.connect(_on_character_leaves_entity_area)
	
# When an NPC emits a collision signal on entry, we show the interact button
# NOTE: Doubling up and doing all entities here
func _on_character_enters_entity_area(body: Node3D):
	var npc_name = body.name
	Util.interact_button_show(body.global_position)
	can_interact = true
	curr_npc = npc_name

func _on_character_leaves_entity_area(_body: Node3D):
	Util.interact_button_hide()
	can_interact = false
	# TODO: If entity is npc... etc.
	# Or I could make something for the entities? Show's a diff dialogue but via yarn?
	hide_dialogue()

func finish_up_dialogue():
	Util.interact_button_hide()
	can_interact = false
	# TODO: Update variables here? The two lines are repeated elsewhere but this is meant to be expanded

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
# TODO: Establish these in a scene's ready function, and then check for a file with the
# saved information (or however state is saved) to load updated values from.
var FLAGS = {
	"checked_for_permit": { # Talk to CitadelGuard
		"value": false,
		"function": on_checked_for_permit,
	},
	"talked_to_old_man": { # Talk to OldMan
		"value": false,
		"function": on_talked_to_old_man,
	},
	"talked_to_sad_guard": { # Talk to SadGuard
		"value": false,
		"function": on_talked_to_sad_guard,
	}
}

# Connected to the variable_storage variable_changes signal
# TODO: We should ensure we have an inverse of this, such that we update whatever yarn is holding on to
# if we change a flag in code (though I'm not sure when that will happen, so I won't worry about for now)
func update_flag(var_name: String, value):
	var flag_name = var_name.substr(1)
	FLAGS[flag_name]["function"].call()
	print("Updating ", var_name, " to ", value)

# All the functions executed on flag change to keep the map somewhat readable
# Remember to let YarnSpinner handle anything dialogue related with the flags
func on_checked_for_permit():
	print("Permit checked!")
	# TODO: Add helper like you did for toggle interactable, will be more readable as I scale
	CUSTOM_NPCS["OldMan"].enable()
	CUSTOM_NPCS["SadGuard"].enable()

# NOTE: Is there a way to show these events are related? Definitely overkill, but if I make
# more complicated things that aren't binary in the future, it's worth noting
# Something like "person helped", since that flag will need to come up
func on_talked_to_old_man():
	print("Talked to old man")
	toggle_npc_interactable("OldMan", false)
	toggle_npc_interactable("SadGuard", false)
	# TODO: Set a global var of who you helped

func on_talked_to_sad_guard():
	print("Talked to sad guard")
	toggle_npc_interactable("SadGuard", false)
	toggle_npc_interactable("OldMan", false)
	# TODO: Set a global var of who you helped

func toggle_npc_interactable(npc_name: String, flag: bool):
	CUSTOM_NPCS[npc_name].set_interactable(flag)
# End of flag execution functions
