extends Node3D
class_name DialogueProjection

@onready var sprite_3d = $DialogueSprite3D
@onready var sub_viewport = $DialogueSprite3D/SubViewport

func _ready():
    sub_viewport.transparent_bg = true
    sub_viewport.size = Vector2i(512, 256)  # Match to your UI size
    sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    sprite_3d.texture = sub_viewport.get_texture() # Can also be done in editor somehow?

func set_viewport_child(node):
    sub_viewport.add_child(node)