extends Control

# Key is NPC name, value is string
# (for now, we'll figure this system out eventually when I dig into yarnspinner)
var npc_dialogue_map = {}

# General parent dialogue control
# As this grows bigger, move things into child scripts. Otherwise, we can just keep it in here for now
func _ready():
	hide()
	connect_to_npc_signals()

func connect_to_npc_signals():
	# The NPC parent MUST be on the same level as our dialogue control node
	var npc_parent_node = get_parent().get_node("NPCs")
	for npc_node in npc_parent_node.get_children():
		var npc: NPCBase = npc_node as NPCBase
		# We have all dialogue loaded up here
		# TODO: Move this global state map to the control mode, i.e. write a "load dialogue" function here
		# This doesn't need to exist on the global state
		# And thus we can remove this line since it's just the same map
		npc_dialogue_map[npc.name] = GlobalState.DIALOGUE_FILE_PATH[npc.name]

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

# When an NPC emits a collision signal on leave, we hide the interact button

# When the interact button is hit and it's visible, show the NPC dialogue that emitted the last entry signal
# TODO: Freeze all other actions -> look into the unhandled_input flow chart again, I think that may be our answer
#       We can just "handle" all input here by sinking it into an empty return
