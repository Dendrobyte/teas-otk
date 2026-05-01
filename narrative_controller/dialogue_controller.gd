extends Control
class_name DialogueController

## DialogueController ##
# This should only be handling show/hide of dialogue, and which dialogue to show
# and when should be predetermined by NarrativeController via some logic
var curr_dialogue = null

## YarnSpinner setup
@onready var dialogue_runner := $YarnDialogueRunner
@onready var line_presenter := $CanvasLayer/LinePresenter
@onready var options_presenter := $CanvasLayer/OptionsPresenter

## End of YarnSpinner setup

signal dialogue_controller_dialogue_finished

# UI elements
@onready var character_name_label = $CanvasLayer/LinePresenter/VBoxContainer/CharacterLabel
@onready var dialogue_text_label = $CanvasLayer/LinePresenter/VBoxContainer/TextLabel
@onready var cont_label = $CanvasLayer/LinePresenter/VBoxContainer/ContinueIndicator
@onready var options_container = $CanvasLayer/OptionsPresenter/OptionsContainer

# General parent dialogue control
# As this grows bigger, move things into child scripts. Otherwise, we can just keep it in here for now
func _ready():
	## YarnSpinner readying setup
	dialogue_runner.add_presenter(line_presenter)
	dialogue_runner.add_presenter(options_presenter)

	# Move to show/hide and dialogue loading
	hide_dialogue()
	dialogue_runner.dialogue_completed.connect(finish_dialogue)

	# Set up the references for UI

# Separate show/hide functions in case I add stuff to show/hide that isn't just the canvas layer
func show_dialogue():
	$CanvasLayer.show()

func hide_dialogue():
	$CanvasLayer.hide()

# NOTE: To be called from NarrativeControl, since that'll "play" animations/events
# Starts a dialogue based on the Godot Node name (which should match the Yarn Node name)
# Returns a signal for dialogue finish that the EventController can
func start_dialogue(yarn_node_name: String):
	# NOTE: This is "proof of concept" code for changing the UI elements
	var char_name = yarn_node_name.get_slice("_", 1) # -1 to get last index doesn't work, OK for prototype
	var char_color = custom_npc_colors.get(char_name, default_color)
	print("Got char name: ", char_name)
	print("Got char color: ", char_color)
	character_name_label.set("theme_override_colors/font_color", char_color)
	dialogue_runner.start_dialogue(yarn_node_name)
	show_dialogue()

	return dialogue_controller_dialogue_finished # I love this pattern

func finish_dialogue():
	# NOTE: Trigger a variable update/processing here if need-be at some point? Depends on conditionals
	dialogue_controller_dialogue_finished.emit()

## UI Stuff ##
## Anything that relates to colors and whatnot shall go here
var custom_npc_colors = {
	"NPC1": Color(.4, .4, 1.0),
	"OldMan": Color(.1, 1.0, .3),
	"SadGuard": Color(.8, .6, .0),
}
var default_color = Color(1.0, 1.0, 1.0)