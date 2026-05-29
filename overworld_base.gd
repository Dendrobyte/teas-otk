extends Node3D

# This overworld base script is for every overworld, so nothing too specific here
func _enter_tree():
	GlobalState.set_gamemode(GlobalState.GameMode.OVERWORLD)
	# TODO: Load assets

# TODO: This is where we'll do things like tallying inventory, saving the game, etc.
# For now (3-30-26) we're just switching the scene over and don't really need to preserve anything
func _exit_tree():
	print("Finished exiting an overworld scene")

# func _ready():
# 	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _input(event):
	# This is duped from brewing base
	if event.is_action_pressed("debug_free_mouse"):
		# TODO: Technically, we'll need "escape" to become a menu thing
		get_tree().quit()