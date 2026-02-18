extends Node3D

func _enter_tree():
	# TODO: I feel like we would switch the gamemode earlier...? Or perhaps we have a loading state and switch it first
	GlobalState.set_gamemode(GlobalState.GameMode.OVERWORLD)
	# TODO: Load assets

	# TODO: I think we should generate this randomly and clump, but this is a good way to test the clump
	
