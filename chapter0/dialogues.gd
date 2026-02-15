extends Control

# TODO: Obviously temporary, load from file
var dialogues = [
	"This is the first scene where two entities are fighting",
	"This is the squad around the fire",
	"This is when the player runs or faces the pivotal moment to set a later scene",
    "Chaptah finished"
]

# TODO: Have the box change positions as it goes, not doing this yet since
# it can/should be a part of the "dynamic" setup we have
var box_positions = []


# The current dialogue index (for now) matches the current scene #
func set_dialogue_text(dialogue_idx):
    $Text.text = dialogues[dialogue_idx]
