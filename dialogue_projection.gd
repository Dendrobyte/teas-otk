extends Node3D
class_name DialogueProjection

@onready var sprite_3d = $DialogueSprite3D
@onready var sub_viewport = $DialogueSprite3D/SubViewport

func _ready():
    # change size?
    # transparent_bg = true
    sprite_3d.texture = sub_viewport.get_texture() # Can also be done in editor somehow?
    position = Vector3.ZERO