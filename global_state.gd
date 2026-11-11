extends Node

#### General enums as consts ####
enum GameMode {MENU, ANIMATIC, OVERWORLD, BREWING, NARRATION}
var CURRENT_GAMEMODE = GlobalState.GameMode.MENU

func set_gamemode(new_gamemode):
	CURRENT_GAMEMODE = new_gamemode

enum TEA_TYPES {NONE = -1, BULLET_GREEN, LAVENDER_MINT, OOLONG, WHITE, LEMON_GINGER, ENGLISH_BREAKFAST}
var _tea_types_strs = {
	TEA_TYPES.NONE: "NULL",
	TEA_TYPES.BULLET_GREEN: "Bullet Green",
	TEA_TYPES.LAVENDER_MINT: "Lavendar Mint",
	TEA_TYPES.OOLONG: "Oolong Tea",
	TEA_TYPES.WHITE: "White Tea",
	TEA_TYPES.LEMON_GINGER: "Lemon Ginger",
	TEA_TYPES.ENGLISH_BREAKFAST: "English Breakfast",
}

# Always pass around the type, convert to string if and when need-be
func get_tea_type_str(tea_type: TEA_TYPES):
	return _tea_types_strs[tea_type]

# We hold on to this largely for yarn nodes. This should eventually become chapter or based on how I organize the yarn files.
# Dialogues are prefixed with the scene type, but we should move to using node names
# So Overworld_Ch1 is the name of the level we load, and thus that's the current scene
var CURRENT_SCENE = ""

func set_current_scene(scene_name):
	CURRENT_SCENE = scene_name

#### High level variables for use across scenes ####
var CURRENT_CHAPTER = 1
func incr_current_chapter():
	CURRENT_CHAPTER = CURRENT_CHAPTER + 1
	if CURRENT_CHAPTER == 4:
		print("No such thing as chapter 4, forced exit... via crash")
		get_tree().root.quit() # yes this just crashes the game lol
var ROTATION_ANGLE = {
	GlobalState.GameMode.OVERWORLD: 0,
	GlobalState.GameMode.BREWING: 0,
}

const BASE_TILE_SIZE = 128

# THESE ARE UNUSED
# Could just increment on what's last and whatever, so for now just using CURRENT_CHAPTER
var OVERWORLD_DAY = 1 # i dont think this changes in the prototype
var BREWING_CHAPTER = 1 # this changes on the last "event" of brewing scene

# maybe store prefs here? {"OldMan", "GreenTea"}?
var BREWING_CHAPTER_CUSTOMER_ORDER = {
	1: [
		{"name": "OldMan", "pref": TEA_TYPES.BULLET_GREEN},
		{"name": "Mercenary", "pref": TEA_TYPES.LAVENDER_MINT},
		{"name": "Forg", "pref": TEA_TYPES.BULLET_GREEN},
		{"name": "General", "pref": TEA_TYPES.OOLONG},
		{"name": "SoldierHurt", "pref": TEA_TYPES.LEMON_GINGER},
		{"name": "SoldierFine", "pref": TEA_TYPES.ENGLISH_BREAKFAST}
		],
	2: [
		{"name": "General", "pref": TEA_TYPES.OOLONG},
		{"name": "OldMan", "pref": TEA_TYPES.LAVENDER_MINT}
		], # and so on for day 2
	3: [
		{"name": "OldMan", "pref": TEA_TYPES.ENGLISH_BREAKFAST}
		],
}

# "Now whenever we run any scene in the project, this script will always be loaded."
# But does that mean it also maintains its state...?
# TODO: Just use this instead? Or just keep using big vars like above?
var game_state = {
	current_scene = null,
}

# Will be either 0 or 1 depending on who you serve the green tea to
var FORG_ENDING = false
var ARMY_ENDING = false
func WHICH_ENDING():
	if FORG_ENDING:
		return "Forg"
	if ARMY_ENDING:
		return "Army"

# TODO: Some on ready or whatever to load saves, blah blah
