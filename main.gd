extends Node3D

@export var narrative_controller: NarrativeController

# NOTE: This will change when we modify how we load current_scene
@export_enum("Overworld", "Brewing") var current_scene_type: String
@export_enum("overworld/overworld_ch1", "brewing/brewing_base_scene", "seal_poc") var scene_tscn_name: String

var game_scene: GameScene

# Not really sure about the entry point yet, but for now we can launch into our narrative start / chapter 0
func _ready():
	# NOTE: We're going to rework this all, I just want something visible rn
	var scene_to_load = load("res://" + scene_tscn_name + ".tscn").instantiate()
	GlobalState.set_current_scene(current_scene_type) # TODO: See global state. We should use node name
	# TODO: Understand why we need to do call_deferred here
	# TODO: Register the chapter's flags with the narrative controller

	game_scene = get_tree().root.get_node("Main").get_node("GameScene")
	game_scene.add_child.call_deferred(scene_to_load)


# Just have this here for now... state management soon:tm:
# NOTE: I really need to figure out how why this "double press" is happening
# TODO: Insta-hop to next scene
var is_transitioning = false
func _input(_delta):
	if Input.is_action_just_pressed("debug_scene_change") and not is_transitioning:
		is_transitioning = true
		if GlobalState.CURRENT_SCENE == "Overworld":
			narrative_controller.transition_scenes("res://brewing/brewing_base_scene.tscn", "Brewing")
		elif GlobalState.CURRENT_SCENE == "Brewing":
			narrative_controller.transition_scenes("res://overworld/overworld_ch1.tscn", "Overworld")
		is_transitioning = false
