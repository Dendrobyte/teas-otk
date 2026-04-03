extends Node
class_name NarrativeController
## Narrative Controller ##
# Every signal gets listened to in NarrativeController and passes to the proper controller
# The response of those processes is all handled in NarrativeController
# All logic and information is done in the main three children
# Primarily, we want to avoid circular deps for any reason
# So collect all information here, and trigger a final result in a child when necessary
# Everything passes through and around here

# There are of course some exceptions where signals can be used to continue
# I think the one instance is when we pause animation for a dialogue bit
# Routing through here would be proper, but that's a case of overkill
# Entity entrance signal isn't done here either, so maybe I'm wrong
# But this is intentional too, since narrative controller doesn't do anything for plants
# TODO: Or... maybe it will... since we could have an InventoryController for later! <:O
##########################

@export var dialogue_controller: DialogueController
@export var event_controller: EventController
@export var entity_controller: EntityController
# @export var character_controller: CharacterController # Abandoning this idea
@export var game_scene: GameScene

var CHARACTER_REF: CharacterBody3D = null
# Hold on to the name of npc in range
# TODO: Find closest NPC, could make helper func in entity_controller
var curr_npc_in_range: String = ""

# We toggle this to control when we show the interact button
var can_interact = false

func _ready():
	if dialogue_controller == null or event_controller == null or entity_controller == null:
		print("Missing a narrative controller required child!")
	
	# Get a signal for the character to emit itself when it loads
	game_scene.character_initialized.connect(func(body): CHARACTER_REF = body)

	# Pass self to children controls
	# TODO: The rest of them (change all to setup, i think initialize is reserved)
	event_controller.initialize(self)
	entity_controller.initialize(self)
	
	# Load all NPC references from the "sibling" game scene
	# 

	# Load all events from some element of the game scene?

	# Connect to yarn signals
	dialogue_controller.dialogue_runner.variable_storage.variable_changed.connect(update_flag)

	# Add general yarn commands
	# Manually register commands, doesn't seem to find it properly despite the output saying a command was registered
	# TODO: Re-verify this claim now that narrative controller has them?
	dialogue_controller.dialogue_runner.add_command("trigger_animation", _yarn_command_trigger_animation)

	# The interact button lives here, so we'll keep it here
	# TODO: May need to make this a control node?
	Util.add_interact_button_to_scene(self)

# TODO: Fiiiix
func _input(event):
	# TODO: Freeze all other actions -> look into the unhandled_input flow chart again, I think that may be our answer
	#       We can just "handle" all input here by sinking it into an empty return
	# TODO: If this dialogue triggers an event change (like talking to the old man), reload their dialogue
	if event.is_action_pressed("interact") and can_interact:
		# TODO: Get the curr_npc_in_range rom entity_controller.get_nearest_entity or whatever
		dialogue_controller.start_dialogue(curr_npc_in_range)
		toggle_interact_button(false)
		# TODO: Listen in somwhere to update this back to true, don't await here

## Dialogue Controller Comms ##
# This will return a signal when it's done, so we can compartmentalize yarn updates, etc.
# TODO: Does returning a signal work? (:
func start_dialogue(yarn_node_name): # Returns the signale
	dialogue_controller.start_dialogue(yarn_node_name)
	return dialogue_controller.dialogue_controller_dialogue_finished

## Event Controller Comms ##
# All flags and events are held in event controller, name based on the flag name
# This function is triggered by changes in Yarn's event controller
# NOTE: We pass the entire npc ref map on purpose. Perhaps later we can whittle it down to relevant ones
# Otherwise, we need an if statement to check which refs we send and that's pointless at this scope
func update_flag(flag_name, value):
	var npc_refs = entity_controller.get_custom_npc_refs()
	event_controller.update_flag_and_call_function(flag_name, value, npc_refs)

# For any command that may be game specific, we can call this
# NOTE: We could also just define a bunch in entity controller if this is used a lot
# and then do it manually if Yarn continues to not detect them automatically
func add_yarn_command(command_name: String, function_ref):
	dialogue_controller.dialogue_runner.add_command(command_name, function_ref)

# To be triggered from yarn files directly. As long as this is in the scene tree it should be found.
# NOTE: Probably remove the underscore if/when used in the code and not just yarn
func _yarn_command_trigger_animation(animation_name):
	print("Triggering animation: ", animation_name)
	event_controller.start_animation(animation_name, CHARACTER_REF)
	# TODO: If this returns a signal, the dialogue pauses until that signal is fired
	# Not sure how I can use that but I probably could

## Entity Controller Comms ##

# TODO: get_nearest_entity

# To be called from within the entity controller as to whether or not we show the interact button
# NOTE: I think (second note on this) we should make this a control node!
func toggle_interact_button(value, position = null):
	can_interact = value
	if value == true:
		# TODO: Get the curr npc ref (see above TODO) and 
		Util.interact_button_show(CHARACTER_REF.position)
	else:
		Util.interact_button_hide()
