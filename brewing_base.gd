extends Node3D

func _enter_tree():
	# TODO: I feel like we would switch the gamemode earlier...? Or perhaps we have a loading state and switch it first
	print("Global state: ", GlobalState)
	GlobalState.set_gamemode(GlobalState.GameMode.BREWING)
	# TODO: Load assets

	print("Finished loading brewing base?")
	
