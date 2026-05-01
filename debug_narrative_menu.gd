extends Control
class_name DebugNarrativeMenu

@onready var item_list = $ItemList

var narrative_controller: NarrativeController
func initialize(narrative_controller_ref: NarrativeController):
	narrative_controller = narrative_controller_ref

	# We load the flags and such from event controller, but eventually
	# event controller should load in from scene- and that should pass to here

	for flag_name in narrative_controller.event_controller.FLAGS:
		item_list.add_item(flag_name)

	item_list.item_clicked.connect(_flag_clicked)

	# TODO: Load related flags from the engine- which can have some master list
	# in the event I need to constantly replay a specific moment
	# Could also make me move to certain coords or whatever, but that'll
	# come when I need it! And definitely in editor. This is just a dialogue skipper.
		
func _flag_clicked(idx, _click_pos, _mouse_btn_idx):
	var flag_text = item_list.get_item_text(idx)
	print("[DEBUG MENU] Clicked flag ", flag_text)

	# Selection happens prior to signal emission
	if item_list.is_selected(idx):
		narrative_controller.update_flag(flag_text, true)
	else:
		narrative_controller.update_flag(flag_text, false)


# TODO: Way later, but some way to "undo" the state of events
# We'll do that if it becomes necessary/easier to just go backwards
