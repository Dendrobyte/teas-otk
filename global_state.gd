extends Node

#### General enums as consts ####
enum GameMode { NARRATIVE, OVERWORLD, BREWING, MENU }
var CURRENT_GAMEMODE = GlobalState.GameMode.NARRATIVE # TODO: Default to menu probably?

func set_gamemode(new_gamemode):
	CURRENT_GAMEMODE = new_gamemode

# We hold on to this largely for yarn nodes. This should eventually become chapter or based on how I organize the yarn files.
var CURRENT_SCENE = ""

func set_current_scene(scene_name):
	CURRENT_SCENE = scene_name

#### High level variables for use across scenes ####
var CURRENT_CHAPTER = null
var ROTATION_ANGLE = {
	GlobalState.GameMode.OVERWORLD: 0,
	GlobalState.GameMode.BREWING: 0,
}

const BASE_TILE_SIZE = 128

# "Now whenever we run any scene in the project, this script will always be loaded."
# But does that mean it also maintains its state...?
var game_state = {
	current_scene = null,
}

# TODO: Some on ready or whatever to load saves, blah blah
