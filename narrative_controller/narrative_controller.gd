extends Node
class_name NarrativeController

@export var dialogue_controller: DialogueController
@export var event_controller: EventController
@export var entity_controller: EntityController
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

	# Get a reference to the character
	
	# Load all NPC references from the "sibling" game scene
	# 

# TODO: Fiiiix
func _input(event):
	# TODO: Freeze all other actions -> look into the unhandled_input flow chart again, I think that may be our answer
	#       We can just "handle" all input here by sinking it into an empty return
	# TODO: If this dialogue triggers an event change (like talking to the old man), reload their dialogue
	if event.is_action_pressed("interact") and can_interact:
		# PICKUP: Left off here
		dialogue_controller.start_dialogue(curr_npc) # Hmm, node names might change over time? Or do I want to organize within yarn?
		show_dialogue()
		Util.interact_button_hide()
		can_interact = false