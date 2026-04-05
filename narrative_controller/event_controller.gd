extends Node3D
class_name EventController

## EVENT TRIGGERING ##
# NOTE: what we need to do is, as this evolves into new scenes, load each overworld level individually
# And each overworld level will have its own set of flags, etc. which we load in
# whenever the narrative control is loaded in
# Except maybe the update_flag function or anything called from yarn spinner listeners
# TODO: This will all come in for that "parent" class to be used by each game scene
# and should effectively be structured like below
# Then this effectively acts like an API, such as the update_flag functions and whatnot

var narrative_controller: NarrativeController
func initialize(narrative_controller_ref: NarrativeController):
	narrative_controller = narrative_controller_ref
	# Load all events from some element of the game scene?

# Holds on to a flag value and the function to call when it changes
# These trigger based on the flag name in our yarn file, but match our global state/saved flags
# The function names can be pulled in, but should be "on_FLAG_NAME" for consistency
# TODO: Establish these in a scene's ready function, and then check for information in that scene with the flags
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

# This is updated every time we send with the update function
var NPC_REFS: Dictionary[String, NPCBase] = {}

# TODO: We should ensure we have an inverse of this, such that we update whatever yarn is holding on to
# if we change a flag in code (though I'm not sure when that will happen, so I won't worry about for now)
func update_flag_and_call_function(var_name: String, value, npc_refs):
	var flag_name = var_name.substr(1)
	NPC_REFS = npc_refs
	print("Given npc refs: ", NPC_REFS)
	# TODO: If flag_name in FLAGS, call() Else don't call and update flag
	FLAGS[flag_name]["function"].call()
	print("Updating ", var_name, " to ", value)

########## TODO ############
# We want to move all of these out into each game scene or something, flags included
# I'll tackle it later, right now it's all pretty concretely coded for scene one
# I wouldn't be opposed to just hiding it in some inherited node like we plan to do
# with the NPC and dialogue stuff
# https://trello.com/c/DGKXi2Ix
# https://trello.com/c/lt8owXUM
############################

# All the functions executed on flag change to keep the map somewhat readable
# Remember to let YarnSpinner handle anything dialogue related with the flags
func on_checked_for_permit():
	print("Permit checked!")
	# TODO: Add helper like you did for toggle interactable, will be more readable as I scale
	NPC_REFS["OldMan"].enable()
	NPC_REFS["SadGuard"].enable()

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

# NOTE: This is the kind of thing that should go narrativectrl -> entityctrl
# It's fine for now since it's super simple, but be careful in case entity controller
# needs to know about this! Though I guess it's an NPC ref property anyway
func toggle_npc_interactable(npc_name: String, flag: bool):
	NPC_REFS[npc_name].set_interactable(flag)

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
func start_animation(animation_name, character_ref):
	cutscene_started.emit()

	var events = animations[animation_name]
	for event in events:
		print("Running event: ", event)
		if event.type == EVENT_TYPE.Animation:
			# NOTE: Do I have to create a tween each time? Feels weird, but might be because dialogue cuts between
			tween = create_tween()
			var move_node_ref 
			if event.node == "Character":
				move_node_ref = character_ref
			else:
				move_node_ref = NPC_REFS[event.node]
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
				tween.parallel().tween_property(move_node_ref, "position", dest_pos, dur_sec)
			else:
				tween.tween_property(move_node_ref, "position", dest_pos, dur_sec)
				await tween.finished
				tween.kill()
		elif event.type == EVENT_TYPE.Dialogue:
			# Tweens are coroutines, so we listen in for the completed step
			var dialogue_completed_signal: Signal = narrative_controller.dialogue_controller.start_dialogue(event.yarn_node)
			await dialogue_completed_signal

	# Clean up the edge case of final tweens being parallel
	# NOTE: We could always add a "stop" instruction that's just "false" that is at the
	# end of every sequence...? But that would just be this exact if statement
	if tween.is_running():
		await tween.finished
		tween.kill()
	
	print("Emitting cutscene ended signal")
	cutscene_ended.emit()

#### END OF ALL THE ANIMATION STUFF ####
