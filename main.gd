extends Node3D

@export var narrative_controller: NarrativeController

# Not really sure about the entry point yet, but for now we can launch into our narrative start / chapter 0
func _ready():
	# NOTE: We're going to rework this all, I just want something visible rn
	var overworld_scene = preload("res://chapter1/chapter_1_overworld.tscn").instantiate()
	# TODO: Understand why we need to do call_deferred here
	# TODO: Register the chapter's flags with the narrative controller
	get_tree().root.add_child.call_deferred(overworld_scene)


# Just have this here for now... state management soon:tm:
func _process(_delta):
	if Input.is_action_pressed("debug_scene_change"):
		scene_change()

# TODO: Fill out properly, next scene based on global state list, etc.
func scene_change():
	print("Switching from overworld to brewing...")
	get_tree().root.get_node("OverworldBase").queue_free()
	var brewing_scene = preload("res://BrewingBase.tscn").instantiate()
	get_tree().root.add_child.call_deferred(brewing_scene)
