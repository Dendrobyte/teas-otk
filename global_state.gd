extends Node

#### General enums as consts ####
enum GameMode { NARRATIVE, EXPLORATION, BREWING, MENU }

#### High level variables for use across scenes ####
var CURRENT_CHAPTER = null
var ROTATION_ANGLE = 45


# "Now whenever we run any scene in the project, this script will always be loaded."
# But does that mean it also maintains its state...?
var game_state = {
	current_scene = null,
}

# TODO: Some on ready or whatever to load saves, blah blah
