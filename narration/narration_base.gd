extends Control
# Base script for the narrative text we want to show
# Yarn file: Narration_All.yarn
# NOTE: Yarn feels unnecessary for the 3 (4) screens we'll need

# We'll just have all the text ready in the control node
# Depending on where we are, we can manually set where we need to be
# The nodes have the same name, and text is labeled numerically
# (We can use this to figure out the centering issue)
var intro_texts = [
	"\nTwo years after leaving the Vanguard, you once again find yourself entering the Citadel.",
	"\nFor over a year now, you've been aiding an Old Man run his tea shop. You've found a certain joy and peace in it.",
	"\nThat is, until familiar signs of unrest and conspiracy begin to show themselves...",
]
var mid_texts = [

]

# Will need to have another one of these
var ending_texts = [

]

# Effectively an iterator?
var all_texts = [intro_texts, mid_texts, ending_texts]
var curr_text_arr_idx = 0

# Tracks index of the texts array we're in
var curr_text = 0

# List of all the text nodes
# Just doing concrete text counts for now
@onready var text_node_1 = $TextList/One
@onready var text_node_2 = $TextList/Two
@onready var text_node_3 = $TextList/Three
@onready var cont = $TextList/Cont

var game_scene: GameScene

func _ready():
	# TODO: I guess I have to pass in whatever one we're on manually, instead of using _ready()
	text_node_1.text = all_texts[curr_text_arr_idx][0]
	curr_text += 1
	cont.hide()

	game_scene = get_parent()

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		show_next_text_in_array(all_texts[curr_text_arr_idx])

# Once the user clicks through, set "game_stage" to "transition"
# Then for that we can switch to ending or whatever
# NOTE: I hate this. Obviously. But here we are
func show_next_text_in_array(text_arr):
	if curr_text == 1:
		text_node_2.text = text_arr[1]
	if curr_text == 2:
		text_node_3.text = text_arr[2]
	if curr_text == 3:
		cont.show()
	if curr_text == 4:
		curr_text = -1
		queue_free()

		if curr_text_arr_idx == 0:
			game_scene.transition_to_scene("res://overworld/overworld_ch1.tscn")
		# elif 1 do brewing
		# elif 2 do end	

		curr_text_arr_idx += 1
	curr_text += 1
	
