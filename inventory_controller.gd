extends Node
class_name InventoryController

#### Everything for stored items, converted to different game phases ####

var narrative_controller: NarrativeController
func initialize(narrative_controller_ref: NarrativeController):
	narrative_controller = narrative_controller_ref
	add_to_group("inventory_controller")

# If the strings really won't change that often, why tf do we use this??
# Why am I so wanting to use constants lol
enum TEA_TYPES { NONE = -1, BULLET_GREEN, MINT, CHAMOMILE, WHITE_TEA, CINNAMON, LAVENDAR_MINT }
var _tea_types_strs = {
	TEA_TYPES.NONE: "NULL",
	TEA_TYPES.BULLET_GREEN: "Bullet Green",
	TEA_TYPES.MINT: "Mint",
	TEA_TYPES.CHAMOMILE: "Chamomile",
	TEA_TYPES.WHITE_TEA: "White Tea",
	TEA_TYPES.CINNAMON: "Cinnamon",
	TEA_TYPES.LAVENDAR_MINT: "Lavendar Mint",
}
func get_type_str(tea_type: TEA_TYPES):
	return _tea_types_strs[tea_type]

# Asset link to preload the teabag
# NOTE: Not sure if this is the best place for this, but the inventory does hold all the tea type stuff?
@onready var teabag_model = preload("res://assets/models/brewing/teabag.glb")
@onready var teabag_script = preload("res://brewing/teabag.gd")

# Create a new teabag from the caller, let them deal with adding it to the tree, etc.
func new_teabag(tea_type):
	var teabag_node = teabag_model.instantiate()
	teabag_node.set_script(teabag_script)
	var teabag_entity = teabag_node as Teabag
	teabag_entity.type = tea_type
	teabag_entity.type_str = get_type_str(tea_type)

	return teabag_entity 

# Container nums are just indices atm so...
# TODO: Use enums
var num_to_info = [
	{ "type": TEA_TYPES.BULLET_GREEN, "quantity": 2 },
	{ "type": TEA_TYPES.MINT, "quantity": 3 },
	{ "type": TEA_TYPES.CHAMOMILE, "quantity": 3 },
	{ "type": TEA_TYPES.WHITE_TEA, "quantity": 0 },
	{ "type": TEA_TYPES.CINNAMON, "quantity": 0 },
	{ "type": TEA_TYPES.LAVENDAR_MINT, "quantity": 0 },
]

func setup_tea_container(container_num):
	return num_to_info[container_num]

func get_teabag(container_num):
	var curr_info = num_to_info[container_num]
	if curr_info.quantity == 0:
		return null
	else:
		# This is not a distributed system
		curr_info.quantity -= 1
		num_to_info[container_num] = curr_info
		return curr_info
