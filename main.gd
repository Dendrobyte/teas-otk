extends Node3D

# Not really sure about the entry point yet, but for now we can launch into our narrative start / chapter 0
func _ready():
	get_tree().change_scene_to_file("res://chapter0/chapter_0.tscn")
