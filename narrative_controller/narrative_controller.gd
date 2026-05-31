extends Control
class_name NarrativeController
## Narrative Controller ##
# TODO: Just make this a singleton at this point... but the node in reference
#		already kind of makes it one? Idk lol
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

@export_group("Parent Scenes")
@export var dialogue_controller: DialogueController
@export var event_controller: EventController
@export var entity_controller: EntityController
@export var inventory_controller: InventoryController
@export var dialogue_projection: DialogueProjection
@export var debug_menu: DebugNarrativeMenu
@export var game_scene: GameScene

var CHARACTER_REF: CharacterController = null
var is_in_dialogue = false
var is_in_cutscene = false

# We toggle this to control when we show the interact button
var can_interact = false
var entity_type: EntityType # NOTE: See the note next to the enum about how this shouldn't live here

func _ready():
	if dialogue_controller == null or event_controller == null or entity_controller == null:
		print("Missing a narrative controller required child!")
	add_to_group("narrative_controller")
	
	# Get a signal for the character setup and entity signals
	game_scene.character_initialized.connect(func(body): CHARACTER_REF = body as CharacterController)
	# Note the thing about change in this function's definition

	# Pass self to children controls and set them up
	# Nil error? Remember: you need to set up the connection in the editor
	dialogue_controller.initialize(self)
	event_controller.initialize(self)
	entity_controller.initialize(self)
	inventory_controller.initialize(self)
	debug_menu.initialize(self)

	# Connect to yarn signals
	dialogue_controller.dialogue_runner.variable_storage.variable_changed.connect(update_flag)

	# Add general yarn commands
	# Need to manually register them here, probably since it's on a different node
	dialogue_controller.dialogue_runner.add_command("trigger_animation", _yarn_command_trigger_animation)
	dialogue_controller.dialogue_controller_dialogue_finished.connect(cleanup_dialogue_finish)
	event_controller.cutscene_ended.connect(cleanup_cutscene_finish)

	# The interact button lives here, so we'll keep it here
	Util.add_interact_button_to_scene(self )

func _input(event):
	# TODO: Freeze all other actions -> look into the unhandled_input flow chart again, I think that may be our answer
	#       We can just "handle" all input here by sinking it into an empty return
	# TODO: If this dialogue triggers an event change (like talking to the old man), reload their dialogue
	if event.is_action_pressed("interact") and can_interact:
		# TODO: For that refactor around NPC/Entities, these could be merged and/or handled in the entity controller
		# The fact this interact is done in narrative controller was a mistake; this is no longer just narrative stuff
		if entity_type == EntityType.NPC:
			var npc_name = entity_controller.get_nearest_npc_name()
			# TODO: Get the curr_npc_in_range from entity_controller.get_nearest_entity or whatever
			dialogue_controller.start_dialogue(GlobalState.CURRENT_SCENE + "_" + npc_name, entity_controller.get_nearest_npc_ref())
			is_in_dialogue = true
		elif entity_type == EntityType.Item:
			var item_name = entity_controller.get_nearest_entity_name()
			entity_controller.collect_resource(item_name)
		toggle_interact_button(false)

## Dialogue Controller Comms ##
func cleanup_dialogue_finish():
	is_in_dialogue = false

# We'll leave the responsibility of adding "$" at callsite
func update_yarn_variable(variable_name, variable_value):
	dialogue_controller.dialogue_runner.variable_storage.set_value(variable_name, variable_value)

## Event Controller Comms ##
# All flags and events are held in event controller, name based on the flag name
# This function is triggered by changes in Yarn's event controller
# NOTE: We pass the entire npc ref map on purpose. Perhaps later we can whittle it down to relevant ones
# Otherwise, we need an if statement to check which refs we send and that's pointless at this scope
func update_flag(flag_name, value):
	var npc_refs = entity_controller.get_custom_npc_refs()
	event_controller.update_flag_and_call_function(flag_name, value, npc_refs)

func cleanup_cutscene_finish():
	is_in_cutscene = false

# For any command that may be game specific, we can call this
# NOTE: We could also just define a bunch in entity controller if this is used a lot
# and then do it manually if Yarn continues to not detect them automatically
func add_yarn_command(command_name: String, function_ref):
	dialogue_controller.dialogue_runner.add_command(command_name, function_ref)

# To be triggered from yarn files directly
# NOTE: Probably remove the underscore if/when used in the code and not just yarn
func _yarn_command_trigger_animation(animation_name):
	print("Triggering animation: ", animation_name)
	# TODO: is in cutscene set to true on the character
	event_controller.start_animation(animation_name, CHARACTER_REF)
	is_in_cutscene = true

## Entity Controller Comms ##
# Currently these apply only in the overworld, and should only be called so?

# TODO: get_nearest_entity

# To be called from within the entity controller as to whether or not we show the interact button
# NOTE: I think (second note on this) we should make this a control node!
# NOTE: No interaction button for brewing, but if you do end up wanting it we would need to ensure character_ref can be whatever
# TODO: If/when we merge NPC and Entity, this enum can be moved elsewhere...
# 		It kind of sucks that narrative controller is suddenly handling the interact change when dialogue may not be involved
#		Or, we could always just add nodes for each of the items! lol
enum EntityType { None, NPC, Item }
func toggle_interact_button(value, interacted_entity_type = EntityType.None, entity_pos = null):
	can_interact = value
	entity_type = interacted_entity_type
	if value == true:
		var button_pos = entity_pos if entity_pos != null else CHARACTER_REF.position
		Util.interact_button_show(button_pos)
	else:
		Util.interact_button_hide()

## Game Scene Comms ##
# TODO: Will revisit this flow in the state design and whatnot
# TODO: Trigger save
# TODO: Fade out
func transition_scenes(new_scene_path, scene_name):
	GlobalState.set_current_scene(scene_name) # Why is this here? It should be set when the scene finishes loading?
	game_scene.unload_scene()
	game_scene.load_scene(new_scene_path)
