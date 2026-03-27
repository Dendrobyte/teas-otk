extends Node3D
class_name AnimationControl

# These are set up in an order of what we want to trigger
enum EVENT_TYPE { Animation, Dialogue }

# NOTE: I don't like this reference here
@export var dialogue_control: DialogueControl

#### ANIMATIONS ####
# TODO: Moving animations out into files etc. Parse things like destination based on some format
# I don't think the names of these functions will match events, we can just
# trigger them manually. The whole thing is quite manual inherently.
# NOTE: Type this? Makes it autocomplete?
var old_man_approaches_at_gate = [
	{"type": EVENT_TYPE.Animation, "node": "OldMan", "dest": Vector3(-61, 0, -1.2), "dur": 1.0, "parallel": false},
	{"type": EVENT_TYPE.Dialogue, "yarn_node": "OldManCitadelEnter"},
	{"type": EVENT_TYPE.Animation, "node": "OldMan", "dest": Vector3(-68, 0, -1.2), "dur": 1.0, "parallel": false},
	# TODO: Some way to pass player "z" pos into here? Replacing any part of the dest, to encourage a straight line
	{"type": EVENT_TYPE.Animation, "node": "OldMan", "dest": Vector3(-68, 0, -0), "dur": 1.0, "parallel": true},
]

# I feel like reflection is how we'd do this without the map and I don't wanna deal with that rn
# But maybe it's easy! Figure it out another time though
var animations = {
	"old_man_approaches_at_gate": old_man_approaches_at_gate,
}

#### END OF ANIMATIONS ####

# TODO: THis is what we move out in dialogue control! We should be accessing
# the refs from elsewhere, not redoing this
var CUSTOM_NPCS: Dictionary[String, NPCBase] = {
	"OldMan": null,
	"SadGuard": null,
}

func _ready():
	var npc_parent_node = get_parent().get_parent().get_node("NPCs")
	for npc_node in npc_parent_node.get_children():
		var npc: NPCBase = npc_node as NPCBase

		# This is where we grab the custom NPCs from the scene's... uh... entities? node? and then register them in here or something
		if CUSTOM_NPCS.has(npc.name):
			CUSTOM_NPCS[npc.name] = npc

var tween
func start_animation(animation_name):
	tween = create_tween()

	var events = animations[animation_name]
	for event in events:
		if event.type == EVENT_TYPE.Animation:
			# TODO: Replacing this with a ref to our external class, wherever that is
			# Should match dialogue control access
			var npc_ref = CUSTOM_NPCS[event.node]
			# TODO: Need to parse this since it'll eventually be from a file. Could just do another map of x/y/z
			var dest_pos: Vector3 = event.dest
			var dur_sec = event.dur
			# The first parallel animation should be set to FALSE
			var is_parallel = event.parallel
			# This is always position... for now. Probably easy to add to the structure of what field we're modifying,
			# and we can use the x/y/z for the same thing
			if is_parallel:
				tween.parallel().tween_property(npc_ref, "position", dest_pos, dur_sec)
			else:
				tween.tween_property(npc_ref, "position", dest_pos, dur_sec)
		elif event.type == EVENT_TYPE.Dialogue:
			dialogue_control.externally_start_dialogue(event.yarn_node)
			# Tweens are coroutines, so we listen in for the completed step
			await dialogue_control.dialogue_runner.dialogue_completed

	tween.kill()
	return 0

# To be triggered from yarn files directly. As long as this is in the scene tree it should be found.
func _yarn_command_trigger_animation(animation_name):
	start_animation(animation_name)

# We assume there is only one active "event stream" happening at a time
# NOTE: I may not need this if we can just listen for the dialogue_completed runner
# func _yarn_command_resume_animation(animation_name):
# 	print("Resuming!")
# 	# Undo the pause which resumes loop iterations
