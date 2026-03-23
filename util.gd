class_name Util

static var interact_button: Sprite3D = Sprite3D.new()
# TODO: Ensure this is cleaned up as we switch out scenes...?
# Everything should be trashed aside from game state, and I don't necessarily
# mind the button living in one spot (dialogue control)
static func add_interact_button_to_scene(some_scene_node):
    var interact_texture = ImageTexture.create_from_image(Image.load_from_file("res://assets/ui/keyboard_e.png"))
    interact_button.texture = interact_texture
    interact_button.scale = Vector3(2, 2, 2)
    some_scene_node.add_child(interact_button)

static func interact_button_hide():
    interact_button.hide()

static func interact_button_show(position):
    position.y = position.y + 4
    interact_button.position = position
    interact_button.show()