extends Node

#### General enums as consts ####
enum GameMode { NARRATIVE, OVERWORLD, BREWING, MENU }
var CURRENT_GAMEMODE = GlobalState.GameMode.NARRATIVE # TODO: Default to menu probably?

func set_gamemode(new_gamemode):
	CURRENT_GAMEMODE = new_gamemode

#### High level variables for use across scenes ####
var CURRENT_CHAPTER = null
var ROTATION_ANGLE = {
	GlobalState.GameMode.OVERWORLD: 0,
	GlobalState.GameMode.BREWING: 0,
}

const BASE_TILE_SIZE = 128

# THIS IS A MAP OF ALL DIALOGUE FOR CHAPTER ONE
# MOVE THIS TO A FILE!!!!
const DIALOGUE_FILE_PATH = {
	"NPC1": "Ey kid... boy, lot of us sure are lookin' worse for wear. // Military sure is convinced they need to give everything to the soldiers but they're forgettin' about their people... *grumble grumble*",
	"NPC2": "JERRY! Stop talkin' to randos out on the street. Help me pack up the crates, we need to set up early today. // _She tosses you an apple_. Be on your way, kid.",
	"NPC3": "Gah... the lines haven't been this long in years!! // That damned population increase...",
	"NPC4": "<Conversation with NPC5>",
	"NPC5": "<Conversation with NPC4>",
	"NPC6": "Permit please!", # "Papers, please!" as a small ode to that game lol
}

# "Now whenever we run any scene in the project, this script will always be loaded."
# But does that mean it also maintains its state...?
var game_state = {
	current_scene = null,
}

# TODO: Some on ready or whatever to load saves, blah blah
