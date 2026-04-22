extends Node3D

@export var narrative_controller: NarrativeController
var game_scene: GameScene

# Not really sure about the entry point yet, but for now we can launch into our narrative start / chapter 0
func _ready():
	# TODO: If testing, always load a specific scene here
	# NOTE: We're going to rework this all, I just want something visible rn
	# var current_scene = preload("res://chapter1/chapter_1_overworld.tscn").instantiate()
	var current_scene = preload("res://brewing/BrewingBase_ch1.tscn").instantiate()
	# var current_scene = preload("res://seal_poc.tscn")
	# TODO: Understand why we need to do call_deferred here
	# TODO: Register the chapter's flags with the narrative controller

	game_scene = get_tree().root.get_node("Main").get_node("GameScene")
	game_scene.add_child.call_deferred(current_scene)


# Just have this here for now... state management soon:tm:
# NOTE: I really need to figure out how why this "double press" is happening
var is_transitioning = false
func _process(_delta):
	if Input.is_action_pressed("debug_scene_change") and not is_transitioning:
		is_transitioning = true
		narrative_controller.transition_scenes("res://BrewingBase_ch1.tscn")
