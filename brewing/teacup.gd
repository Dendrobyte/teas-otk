extends Node3D
class_name TeaCup

@export var is_filled: bool = false:
    set(value):
        is_filled = value
        if is_node_ready(): toggle_water(value)

@export var has_teabag: bool = false:
    set(value):
        has_teabag = value
        if is_node_ready(): toggle_teabag(value)

func _ready():
    print("Loaded cup: ", name)

func toggle_water(value):
    if value:
        $Water.show()
    else:
        $Water.hide()

func toggle_teabag(value):
    if value:
        $Teabag.show()
    else:
        $Teabag.hide()