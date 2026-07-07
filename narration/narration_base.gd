extends Control
# Base script for the narrative text we want to show
# Yarn file: Narration_All.yarn
# NOTE: If yarn feels too complicated/annoying, maybe just hardcode the 3 (4?) text values we'll have

var game_stage = "intro"

var stages = ["intro", "transition", "ending"]

func _ready():
    # PICKUP: Queue up the intro text to show
    # Once the user clicks through, set "game_stage" to "transition"
    # Then for that we can switch to ending or whatever
    print("Curr stage: ", game_stage)