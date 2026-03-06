extends Control

# Key is NPC name, value is string
# (for now, we'll figure this system out eventually when I dig into yarnspinner)
var npc_dialogue_map = {}

# General parent dialogue control
# As this grows bigger, move things into child scripts. Otherwise, we can just keep it in here for now
func _ready():
	hide()
	load_dialogue()
	connect_to_npc_signals()

# TODO: THIS IS A MAP OF ALL DIALOGUE FOR CHAPTER ONE
# MOVE THIS TO A FILE!!!!
func load_dialogue():
	npc_dialogue_map = {
		"NPC1": "Ey kid... boy, lot of us sure are lookin' worse for wear. // Military sure is convinced they need to give everything to the soldiers but they're forgettin' about their people... *grumble grumble*",
		"NPC2": "JERRY! Stop talkin' to randos out on the street. Help me pack up the crates, we need to set up early today. // _She tosses you an apple_. Be on your way, kid.",
		"NPC3": "Gah... the lines haven't been this long in years!! // That damned population increase...",
		"NPC4": "<Conversation with NPC5>",
		"NPC5": "<Conversation with NPC4>",
		"NPC6": "Permit please!", # "Papers, please!" as a small ode to that game lol
	} 

func connect_to_npc_signals():
	# The NPC parent MUST be on the same level as our dialogue control node
	var npc_parent_node = get_parent().get_node("NPCs")
	for npc_node in npc_parent_node.get_children():
		var npc: NPCBase = npc_node as NPCBase

		npc.npc_collision_enter.connect(_on_character_enters_npc_area)
		npc.npc_collision_leave.connect(_on_character_leaves_npc_area)
	
# When an NPC emits a collision signal on entry, we show the interact button
# TODO: Set the current dialogue... and maybe that cascades into 
func _on_character_enters_npc_area(body: Node3D):
	var npc_name = body.name
	print("NPC says: ", npc_dialogue_map[npc_name])

func _on_character_leaves_npc_area(body: Node3D):
	var npc_name = body.name
	print("NPC ", npc_name, " button hides on exit")

# When the interact button is hit and it's visible, show the NPC dialogue that emitted the last entry signal
# TODO: Freeze all other actions -> look into the unhandled_input flow chart again, I think that may be our answer
#       We can just "handle" all input here by sinking it into an empty return
