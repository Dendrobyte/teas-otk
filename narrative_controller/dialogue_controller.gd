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

# General parent dialogue control
# As this grows bigger, move things into child scripts. Otherwise, we can just keep it in here for now
func _ready():
	## YarnSpinner readying setup
	dialogue_runner.add_presenter(line_presenter)
	dialogue_runner.add_presenter(options_presenter)

	# Move to show/hide and dialogue loading
	hide_dialogue()
	dialogue_runner.dialogue_completed.connect(finish_dialogue)

# Separate show/hide functions in case I add stuff to show/hide that isn't just the canvas layer
func show_dialogue():
	$CanvasLayer.show()

func hide_dialogue():
	$CanvasLayer.hide()

# NOTE: To be called from NarrativeControl, since that'll "play" animations/events
# Starts a dialogue based on the Godot Node name (which should match the Yarn Node name)
func start_dialogue(yarn_node_name):
	dialogue_runner.start_dialogue(yarn_node_name)
	show_dialogue()

func finish_dialogue():
	# TODO: Update variables here? The two lines are repeated elsewhere but this is meant to be expanded
	dialogue_controller_dialogue_finished.emit()
