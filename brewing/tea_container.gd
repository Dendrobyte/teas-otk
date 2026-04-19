extends Node3D
class_name TeaContainer
# TODO: TeaContainer

var tea_type = "Bullet_Green" # TODO: Sort the specific teas out way later

func interact(player_node):
	if player_node.get_held_item_min_name() not in ["teabag", "TeaCup"]:
		var teabag = player_node.new_teabag()
		teabag.scale = Vector3(teabag.scale.x*.5, teabag.scale.y*.5, teabag.scale.z*.5)
		player_node.set_held_item(teabag)
		return "Teabag picked up"

