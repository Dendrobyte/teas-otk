extends Control

# General parent dialogue control
# As this grows bigger, move things into child scripts. Otherwise, we can just keep it in here for now
func _ready():
    hide()

# When an NPC emits a collision signal on entry, we show the interact button

# When an NPC emits a collision signal on leave, we hide the interact button

# When the interact button is hit and it's visible, show the NPC dialogue that emitted the last entry signal
# TODO: Freeze all other actions -> look into the unhandled_input flow chart again, I think that may be our answer
#       We can just "handle" all input here by sinking it into an empty return