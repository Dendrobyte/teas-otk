extends Node3D

# This overworld base script is for every overworld, so nothing too specific here
func _enter_tree():
	GlobalState.set_gamemode(GlobalState.GameMode.OVERWORLD)
	# TODO: Load assets

	# TODO: I think we should generate this randomly and clump, but this is a good way to test the clump
	
