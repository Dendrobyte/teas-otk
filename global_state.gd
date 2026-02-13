extends Node

#### General enums as consts ####
enum GameMode { NARRATIVE, OVERWORLD, BREWING, MENU }
var CURRENT_GAMEMODE = GlobalState.GameMode.NARRATIVE # TODO: Default to menu probably?

func set_gamemode(new_gamemode):
	CURRENT_GAMEMODE = new_gamemode

#### High level variables for use across scenes ####
var CURRENT_CHAPTER = null
var ROTATION_ANGLE = {
	GlobalState.GameMode.OVERWORLD: 45,
	GlobalState.GameMode.BREWING: 0,
}


# "Now whenever we run any scene in the project, this script will always be loaded."
# But does that mean it also maintains its state...?
var game_state = {
	current_scene = null,
}

# TODO: Some on ready or whatever to load saves, blah blah
