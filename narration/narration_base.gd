extends Control
# Base script for the narrative text we want to show
# Yarn file: Narration_All.yarn
# NOTE: Yarn feels unnecessary for the 3 (4) screens we'll need

# We'll just have all the text ready in the control node
# Depending on where we are, we can manually set where we need to be
# The nodes have the same name, and text is labeled numerically
# (We can use this to figure out the centering issue)
var stages = ["intro", "transition", "ending"]
var curr_stage = 0

# List of all the text nodes
# Just doing concrete text counts for now
@onready var text_node_1 = $1

func _ready():
    # PICKUP: Queue up the intro text to show using above text nodes
    # Once the user clicks through, set "game_stage" to "transition"
    # Then for that we can switch to ending or whatever
    print("Curr stage: ", curr_stage)