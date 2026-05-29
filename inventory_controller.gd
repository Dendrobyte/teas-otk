extends Node
class_name InventoryController

#### Everything for stored items, converted to different game phases ####

var narrative_controller: NarrativeController
func initialize(narrative_controller_ref: NarrativeController):
	narrative_controller = narrative_controller_ref
