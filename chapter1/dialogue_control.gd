extends Control

#### SCOPE ####
# The dialogue control should ONLY handle:
# 	1. The loading of dialogue per NPC to be displayed with a dialogue box
#	2. Show/hide of interaction button
#	3. It can trigger event updates
# It should contain NONE of the branching flow, etc. Just loading "what's next" for an NPC

# Key is NPC name, value is string
# (for now, we'll figure this system out eventually when I dig into yarnspinner)
var npc_dialogue_map = {}
var interact_button: Sprite3D = Sprite3D.new()
var can_interact = false # I feel like this interaction button thing can become a separate script, if only to modularize it with item gathering
var curr_dialogue = null

## NPC STUFF! / what i want to move out of here
# This is also meant to be moved out like the events at the bottom
var curr_npc = null # merge with above, see note about blob
var old_man: NPCBase = null

## End of NPC stuff

# General parent dialogue control
# As this grows bigger, move things into child scripts. Otherwise, we can just keep it in here for now
func _ready():
	# hide()
	load_dialogue()
	connect_to_npc_signals()

	# Set up the interact button
	var interact_texture = ImageTexture.create_from_image(Image.load_from_file("res://assets/ui/keyboard_e.png"))
	interact_button.texture = interact_texture
	interact_button.scale = Vector3(2, 2, 2)
	add_child(interact_button)
	interact_button.hide()

func _input(event):
	# TODO: Freeze all other actions -> look into the unhandled_input flow chart again, I think that may be our answer
	#       We can just "handle" all input here by sinking it into an empty return
	# TODO: If this dialogue triggers an event change (like talking to the old man), reload their dialogue
	if event.is_action_pressed("interact") and can_interact:
		print(curr_npc + " says " + curr_dialogue)
		check_npc_event(curr_npc)


# TODO: THIS IS A MAP OF ALL DIALOGUE FOR CHAPTER ONE
# MOVE THIS TO A FILE!!!!
# Note: Just to store notes on dialogue systems, the "dialogue" should always be a blob
# That way we can use the npc name to retrieve it but the NPC "actual name" will be in the blob to then show in a diff field
# Such as when we interact, it's curr_dialogue.name + ": " + curr_dialogue.text_start or something
func load_dialogue():
	npc_dialogue_map = {
		"NPC1": "Ey kid... boy, lot of us sure are lookin' worse for wear. // Military sure is convinced they need to give everything to the soldiers but they're forgettin' about their people... *grumble grumble*",
		"NPC2": "JERRY! Stop talkin' to randos out on the street. Help me pack up the crates, we need to set up early today. // _She tosses you an apple_. Be on your way, kid.",
		"NPC3": "Gah... the lines haven't been this long in years!! // That damned population increase...",
		"NPC4": "<Conversation with NPC5>",
		"NPC5": "<Conversation with NPC4>",
		"CitadelGuard":
			{
				"flag_talked_to_old_man_false": "Permit please!", # "Papers, please!" as a small ode to that game lol
				"flag_talked_to_old_man_true": "Welcome in, you two",
			},
		"OldMan": "Ah, hello there young fellow!",
	}

func connect_to_npc_signals():
	# The NPC parent MUST be on the same level as our dialogue control node
	var npc_parent_node = get_parent().get_node("NPCs")
	for npc_node in npc_parent_node.get_children():
		var npc: NPCBase = npc_node as NPCBase

		npc.npc_collision_enter.connect(_on_character_enters_npc_area)
		npc.npc_collision_leave.connect(_on_character_leaves_npc_area)

		if npc.name == "OldMan":
			old_man = npc
			old_man.hide() # This doesn't hide the hitbox
	
# When an NPC emits a collision signal on entry, we show the interact button
# TODO: Set the current dialogue... and maybe that cascades into 
func _on_character_enters_npc_area(body: Node3D):
	var npc_name = body.name
	var location = body.global_position
	location.y = location.y + 5
	interact_button.position = location
	interact_button.show()
	can_interact = true
	curr_dialogue = npc_dialogue_map[npc_name]

	## EVENT TRIGGERING ##
	# This is the place where I want something that could potentially be more dynamic...
	# Like checking this flag on every character here- is that a good place for it?
	# Or is it better to update a new map of dialogue with "what should be said given the current state"
	# when the state changes?
	# I don't like that this is so conditional here, so tracking it "elsewhere" would make it more
	# readable- i.e. the above line npc_dialogue_map[npc_name] would be the only line we need
	if npc_name == "CitadelGuard":
		if flag_talked_to_old_man == false:
			curr_dialogue = curr_dialogue["flag_talked_to_old_man_false"]
		else:
			curr_dialogue = curr_dialogue["flag_talked_to_old_man_true"]

	curr_npc = npc_name

func _on_character_leaves_npc_area(_body: Node3D):
	interact_button.hide()
	can_interact = false

## EVENT TRIGGERING ##
# I don't like that this is in the dialogue control. It has nothing to do with dialogue. But I think
# we can have some script tracking the events of the "current scene" and then when it changes we update our
# global state. Then we save that global state with all those independent fields
# And somehow each scene will have potential events and such to trigger, as opposed to all of them
# being in one huge file

var flag_checked_for_permit = false
var flag_talked_to_old_man = false
func check_npc_event(npc_name):
	if npc_name == "CitadelGuard":
		flag_checked_for_permit = true
		old_man.show()
	if npc_name == "OldMan":
		flag_talked_to_old_man = true
