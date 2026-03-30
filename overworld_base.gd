extends Node3D

# This overworld base script is for every overworld, so nothing too specific here
func _enter_tree():
	GlobalState.set_gamemode(GlobalState.GameMode.OVERWORLD)
	# TODO: Load assets

	# TODO: I think we should generate this randomly and clump, but this is a good way to test the clump
	
# TODO: This is where we'll do things like tallying inventory, saving the game, etc.
# For now (3-30-26) we're just switching the scene over and don't really need to preserve anything
func _exit_tree():
	print("Finished exiting an overworld scene")