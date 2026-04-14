extends Node3D
class_name Kettle

var kettle_parent: Node3D = null
var kettle_origin_position = null # TODO: Change to a transform that holds rotation too?

var is_boiled = 0
var water_level = 0

func _ready():
    kettle_parent = get_parent()
    kettle_origin_position = position

func interact(player_node):
    if player_node.held_item == null and not is_boiled:
        # Why the fuck do I even have this? When I add a timer it'll make more sense, I swear!
        is_boiled = true
        return "Boiled the kettle!"
    elif player_node.held_item == null and is_boiled:
        player_node.set_held_item(self)
        reparent(player_node)
        return "Picked up the kettle!"
    else:
        return "Unhandled kettle interaction"
    

func reset_position():
    reparent(kettle_parent)
    position = kettle_origin_position