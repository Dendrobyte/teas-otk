extends Node3D
class_name TeaServeTray

# For now, this only clears when someone says something? Not sure it's necessary since
# we'll- in theory- pause the game when a cup is served
# Not sure why I'm preparing for multiple cups being served at once lol
# Plus, maybe we serve a whole tray of tea in the future, but rn just one
var placed_cup_node: TeaCup = null

func interact(player_node):
    var held_item = player_node.held_item
    if held_item == null and placed_cup_node != null:
        placed_cup_node.queue_free()
        return "Cup removed from tray"
    elif player_node.get_held_item_min_name() == "TeaCup" and placed_cup_node != null:
        return "There is already a cup on the tray!"
    elif player_node.get_held_item_min_name() == "TeaCup" and placed_cup_node == null:
        var cup_node = player_node.held_item as TeaCup
        if cup_node.can_be_served():
            placed_cup_node = cup_node
            # NOTE: could make this a function of each item too, used in tea_serve
            # Namely, for this "position on and reparent to interacted object and reset held item"
            placed_cup_node.place(global_position)
            placed_cup_node.tray_ref = self
            placed_cup_node.reparent(self)
            player_node.set_held_item(null)
            return "Placed cup on serving tray!"
        else:
            return "Cup cannot be served!"

# I just feel like I might have to do more here? Idk
func clear_tray():
    placed_cup_node = null
    