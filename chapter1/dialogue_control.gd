extends Control
class_name DialogueControl

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
# Or anything that might be referenced in an animation
# Should be hard written like the flags end up being
# Every key in here MUST match the node name of NPCs in the Godot Scene
var CUSTOM_NPCS: Dictionary[String, NPCBase] = {
	"OldMan": null,
	"SadGuard": null,
	"CitadelGuard": null,
}

var CHARACTER_REF: CharacterBody3D = null

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
	CHARACTER_REF = get_parent().get_node("Character")

	# Manually register commands, doesn't seem to find it properly despite the output saying a command was registered
	# TODO: Solve this a little better in the refactor...
	dialogue_runner.add_command("trigger_animation", _yarn_command_trigger_animation)

	# The interact button lives here I guess... it's technically UI?
	Util.add_interact_button_to_scene(self)

func _input(event):
	# TODO: Freeze all other actions -> look into the unhandled_input flow chart again, I think that may be our answer
	#       We can just "handle" all input here by sinking it into an empty return
	# TODO: If this dialogue triggers an event change (like talking to the old man), reload their dialogue
	if event.is_action_pressed("interact") and can_interact:
		dialogue_runner.start_dialogue(curr_npc) # Hmm, node names might change over time? Or do I want to organize within yarn?
		show_dialogue()
		Util.interact_button_hide()
		can_interact = false

# NOTE: Maybe move this out? It's so that we can trigger from the animation control
func externally_start_dialogue(yarn_node_name):
	dialogue_runner.start_dialogue(yarn_node_name)
	show_dialogue()

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

# TODO: I should have some conditional for this happening?
# Unsure if necessary seeing as this triggers upon dialogue end
func on_talked_to_sad_guard():
	print("Talked to sad guard")
	toggle_npc_interactable("OldMan", false)
	# TODO: Set a global var of who you helped

func toggle_npc_interactable(npc_name: String, flag: bool):
	CUSTOM_NPCS[npc_name].set_interactable(flag)
# End of flag execution functions

# Obviously, this needs to be all moved out
#### ANIMATIONS ####

# These are set up in an order of what we want to trigger
enum EVENT_TYPE { Animation, Dialogue }

signal cutscene_started
signal cutscene_ended

# TODO: Moving animations out into files etc. Parse things like destination based on some format
# I don't think the names of these functions will match events, we can just
# trigger them manually. The whole thing is quite manual inherently.
# NOTE: Type this? Makes it autocomplete?
# TODO: Make a "teleport" command that isn't a tween but sets a position
# For example, the old man shouldn't zoom in from the other side of the bridge
# TODO: Any use of a "pause" instruction? Or some "react" instruction that changes the sprite? That could be cool

# Triggers when you talk to the guard outside the gate after helping the old man
# We also just run this with the sad guard
var old_man_approaches_at_gate = [
	{"type": EVENT_TYPE.Animation, "node": "OldMan", "dest": Vector3(-61, 0, -1.2), "dur": 1.0, "parallel": false},
	{"type": EVENT_TYPE.Dialogue, "yarn_node": "OldManCitadelEnter"},
	{"type": EVENT_TYPE.Animation, "node": "OldMan", "dest": Vector3(-68, 0, -1.2), "dur": 1.0, "parallel": true},
	# TODO: Some way to pass player "z" pos into here? Replacing any part of the dest, to encourage a straight line
	{"type": EVENT_TYPE.Animation, "node": "Character", "dest": Vector3(-84, 5.231, -2.7), "dur": 1.0, "parallel": true},
]

# Triggers when you cheer up the sad guard and removes the current guard there
var sad_guard_replaces_other_guard = [
	{"type": EVENT_TYPE.Animation, "node": "SadGuard", "dest": Vector3(-64.354, 0, -2.473), "dur": 1.5, "parallel": false},
	{"type": EVENT_TYPE.Animation, "node": "CitadelGuard", "dest": Vector3(-64.354, 0, 2.139), "dur": 2.0, "parallel": false},
	{"type": EVENT_TYPE.Animation, "node": "SadGuard", "dest": Vector3(-64.354, 0, -1.091), "dur": 2.0, "parallel": false},
	# TODO: Rotate the guard; I need a "type" and can just base it off of the types in tweening
	# {"type": EVENT_TYPE.Animation, "node": "SadGuard", "dest": Vector3(-64.354, 0, -1.091), "dur": 2.0, "parallel": false},
	# TODO: This is where the reaction / sprite change instruction comes in. Change to sad_guard_happy or some shit haha, to be animated in the future
	# but an instruction for sprite animation can come later; that's where the pause would come in despite it being short?
	# The timing will be a whole other thing, but anyway
	# {"type": EVENT_TYPE.Animation, "node": "SadGuard", "dest": Vector3(-64.354, 0, -1.091), "dur": 2.0, "parallel": false},
]

# I feel like reflection is how we'd do this without the map and I don't wanna deal with that rn
# But maybe it's easy! Figure it out another time though
var animations = {
	"old_man_approaches_at_gate": old_man_approaches_at_gate,
	"sad_guard_replaces_other_guard": sad_guard_replaces_other_guard,
}

#### END OF ANIMATIONS ####
var tween
func start_animation(animation_name):
	cutscene_started.emit()

	var events = animations[animation_name]
	for event in events:
		print("Running event: ", event)
		if event.type == EVENT_TYPE.Animation:
			# NOTE: Do I have to create a tween each time? Feels weird, but might be because dialogue cuts between
			tween = create_tween()
			# TODO: Replacing this with a ref to our external class, wherever that is
			# Should match dialogue control access
			# TODO: I don't like this. It's ok for now but if we move more than just NPCs...?
			var npc_ref
			if event.node == "Character":
				npc_ref = CHARACTER_REF
			else:
				npc_ref = CUSTOM_NPCS[event.node]
			# TODO: Need to parse this since it'll eventually be from a file. Could just do another map of x/y/z
			var dest_pos: Vector3 = event.dest
			var dur_sec = event.dur
			# The first parallel animation should be set to FALSE
			var is_parallel = event.parallel
			# This is always position... for now. Probably easy to add to the structure of what field we're modifying,
			# and we can use the x/y/z for the same thing
			# NOTE: When running parallel tweens, BOTH need parallel set to true
			# At least with this setup, we need to ensure we don't await finish nor kill it before it's done
			if is_parallel:
				tween.parallel().tween_property(npc_ref, "position", dest_pos, dur_sec)
			else:
				tween.tween_property(npc_ref, "position", dest_pos, dur_sec)
				await tween.finished
				tween.kill()
		elif event.type == EVENT_TYPE.Dialogue:
			externally_start_dialogue(event.yarn_node)
			# Tweens are coroutines, so we listen in for the completed step
			await dialogue_runner.dialogue_completed

	# Clean up the edge case of final tweens being parallel
	# NOTE: We could always add a "stop" instruction that's just "false" that is at the
	# end of every sequence...? But that would just be this exact if statement
	if tween.is_running():
		await tween.finished
		tween.kill()
	
	print("Emitting cutscene ended signal")
	cutscene_ended.emit()

# To be triggered from yarn files directly. As long as this is in the scene tree it should be found.
# NOTE: Probably remove the underscore if/when used in the code and not just yarn
func _yarn_command_trigger_animation(animation_name):
	print("Triggering animation: ", animation_name)
	start_animation(animation_name)
	# TODO: If this returns a signal, the dialogue pauses until that signal is fired
	# Not sure how I can use that but I probably could

#### END OF ALL THE ANIMATION STUFF ####
