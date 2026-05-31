extends Node
class_name InventoryController

#### Everything for stored items, converted to different game phases ####

var narrative_controller: NarrativeController
func initialize(narrative_controller_ref: NarrativeController):
	narrative_controller = narrative_controller_ref
	add_to_group("inventory_controller")

# Container nums are just indices atm so...
var num_to_info = [
	{ "type": "Bullet_Green", "quantity": 2 },
	{ "type": "Mint", "quantity": 3 },
	{ "type": "Chamomile", "quantity": 3 },
	{ "type": "White Tea", "quantity": 0 },
	{ "type": "Cinnamon", "quantity": 0 },
	{ "type": "Lavendar Mint", "quantity": 0 },
]

func setup_tea_container(container_num):
	return num_to_info[container_num]