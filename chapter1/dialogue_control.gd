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
# I think this one can be held onto in the dialogue control, as it indicates whose dialogue we show
var curr_npc = null

# Some map of all NPCs whose behavior we need to tweak
# Should be hard written like the flags end up being
# Every key in here MUST match the node name of NPCs in the Godot Scene
var CUSTOM_NPCS: Dictionary[String, NPCBase] = {
	"OldMan": null,
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

		# This is where we grab the custom NPCs from the scene's... uh... entities? node? and then register them in here or something
		if CUSTOM_NPCS.has(npc.name):
			CUSTOM_NPCS[npc.name] = npc
	
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

func finish_up_dialogue():
	interact_button.hide()
	can_interact = false

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
	"talked_to_old_man": { # Talk to CitadelGuard
		"value": false,
		"function": on_talked_to_old_man,
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
	CUSTOM_NPCS["OldMan"].enable()

func on_talked_to_old_man():
	print("Talked to old man!")
	CUSTOM_NPCS["OldMan"].set_interactable(false)

# End of flag execution functions
