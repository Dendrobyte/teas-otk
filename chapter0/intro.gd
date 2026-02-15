extends Node3D

var scene_nodes = ["Scene0", "Scene1", "Scene2"]

# Should be set to the full scene path (or reference?)
var current_scene = null

# NOTE: We'll just trigger the entry into the menu/chapter one instead
# This is just for logical flow for next_scene and input
var is_going = true

func _ready():
	GlobalState.set_gamemode(GlobalState.GameMode.NARRATIVE)
	current_scene = -1
	next_scene()

# TODO: Uhhh probably better to create an event in the editor
func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and is_going:
		next_scene()

func next_scene():
	get_node(scene_nodes[current_scene]).visible = false
	current_scene += 1
	if current_scene >= len(scene_nodes):
		is_going = false
	else:
		get_node(scene_nodes[current_scene]).visible = true
	$Dialogues.set_dialogue_text(current_scene)
