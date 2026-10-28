extends Node

#### General enums as consts ####
enum GameMode {MENU, ANIMATIC, OVERWORLD, BREWING, NARRATION}
var CURRENT_GAMEMODE = GlobalState.GameMode.MENU

func set_gamemode(new_gamemode):
	CURRENT_GAMEMODE = new_gamemode

# We hold on to this largely for yarn nodes. This should eventually become chapter or based on how I organize the yarn files.
# Dialogues are prefixed with the scene type, but we should move to using node names
# So Overworld_Ch1 is the name of the level we load, and thus that's the current scene
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

var OVERWORLD_DAY = 1 # i dont think this changes in the prototype
var BREWING_CHAPTER = 1 # this changes on the last "event" of brewing scene

# maybe store prefs here? {"OldMan", "GreenTea"}?
var BREWING_CHAPTER_CUSTOMER_ORDER = {
	1: ["OldMan", "Mercenary", "Forg", "General", "SoldierHurt", "SolderFine"],
	2: [], # and so on for day 2
}

# "Now whenever we run any scene in the project, this script will always be loaded."
# But does that mean it also maintains its state...?
# TODO: Just use this instead? Or just keep using big vars like above?
var game_state = {
	current_scene = null,
}

# TODO: Some on ready or whatever to load saves, blah blah
