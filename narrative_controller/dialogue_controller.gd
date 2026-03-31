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

# General parent dialogue control
# As this grows bigger, move things into child scripts. Otherwise, we can just keep it in here for now
func _ready():
	## YarnSpinner readying setup
	dialogue_runner.add_presenter(line_presenter)
	dialogue_runner.add_presenter(options_presenter)
	# I wish I had elixir lambda here
	dialogue_runner.variable_storage.variable_changed.connect(update_flag)

	# Move to show/hide and dialogue loading
	hide_dialogue()
	dialogue_runner.dialogue_completed.connect(finish_dialogue)

	# Manually register commands, doesn't seem to find it properly despite the output saying a command was registered
	# TODO: Solve this a little better in the refactor...
	dialogue_runner.add_command("trigger_animation", _yarn_command_trigger_animation)

	# The interact button lives here I guess... it's technically UI?
	Util.add_interact_button_to_scene(self)


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
	Util.interact_button_hide()
	can_interact = false
	# TODO: Update variables here? The two lines are repeated elsewhere but this is meant to be expanded
