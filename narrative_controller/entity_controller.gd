extends Node
class_name EntityController

var narrative_controller: NarrativeController
func initialize(narrative_controller_ref: NarrativeController):
	narrative_controller = narrative_controller_ref

	narrative_controller.game_scene.npc_initialized.connect(init_npc_base)
	narrative_controller.game_scene.entity_initialized.connect(init_item_base)

# TODO
# We'll get to this next with the entity refactors
# For now, just scrap together what works with the most simplicity
# Remove the strings. It'll be "NodeName" -> ref
# loaded in programmatically from game scene
# These should match however the flags are done for a game scene, barring
# the exception that flags may also be omnipresent as we set them
# 
# Some map of all NPCs whose behavior we need to tweak
# Or anything that might be referenced in an animation
# Every key in here MUST match the node name of NPCs in the Godot Scene
# 
# Is this used anymore? Since we load from images? Like, "Mercenary" isn't in here...
var CUSTOM_NPCS: Dictionary[String, NPCBase] = {
	"OldMan": null,
	"SadGuard": null,
	"CitadelGuard": null,
}

func get_custom_npc_refs():
	return CUSTOM_NPCS

# NOTE: Could make NPCs just another entity
# 		I could see a world where EntityBase is parent of NPCBase and ItemBase
# 		They use the same logic for emitting a signal and the split only happens in this two funcs
# Both of these init functions call for the individual entity when it loads in
func init_npc_base(npc: NPCBase):
	npc.npc_collision_enter.connect(_on_character_enters_npc_area)
	npc.npc_collision_leave.connect(_on_character_leaves_npc_area)
	# TODO: See bigger note above, but don't hard code these values p much
	if CUSTOM_NPCS.has(npc.name):
		CUSTOM_NPCS[npc.name] = npc

func init_item_base(item_node: EntityBase):
	var entity: EntityBase = item_node as EntityBase

	entity.entity_collision_enter.connect(_on_character_enters_entity_area)
	entity.entity_collision_leave.connect(_on_character_leaves_entity_area)

func get_entity_ref(node_name: String):
	return CUSTOM_NPCS[node_name]

# NOTE: Do we want to return a ref instead at this point? Ref used for position when showing dialogue.
# NOTE: Don't really need the get functions, but makes more sense when writing code to me?
# TODO: See ticket about refactoring the entitytype stuff :\
var curr_npc_in_range_name: String
func get_nearest_npc_name():
	return curr_npc_in_range_name

# Entity names need to be "minified" and stripped of number
var curr_entity_in_range_name: String
func get_nearest_entity_name():
	return curr_entity_in_range_name.rstrip("0123456789")

var curr_npc_in_range: Node3D
func get_nearest_npc_ref():
	return curr_npc_in_range

var curr_entity_in_range: Node3D
func get_nearest_entity_ref():
	return curr_entity_in_range

# When an NPC emits a collision signal on entry, we show the interact button
# TODO: If there already is an NPC held on to, we only save the closest one
#		For now, we just replace. Should become a list ordered by close-ness
# TODO: This triggers on init based on print statements. Does that become a problem?
# NOTE: See above about merging the entity stuff, even these are almost identical and
#		the code path changes depending on what we're interacting with
func _on_character_enters_npc_area(body: Node3D):
	curr_npc_in_range = body
	curr_npc_in_range_name = body.name
	narrative_controller.toggle_interact_button(true, narrative_controller.EntityType.NPC, body.global_position)

func _on_character_leaves_npc_area(_body: Node3D):
	# TODO: Bump the list down if there are more entities around
	#		Otherwise we're just clearing the entity from the list
	narrative_controller.toggle_interact_button(false)

# NOTE: Refactor... -.-
func _on_character_enters_entity_area(body: Node3D):
	print("Curr entity is: ", body, " and name is: ", body.name)
	curr_entity_in_range = body
	curr_entity_in_range_name = body.name
	narrative_controller.toggle_interact_button(true, narrative_controller.EntityType.Item, body.global_position)

func _on_character_leaves_entity_area(_body: Node3D):
	narrative_controller.toggle_interact_button(false)

#### I shouldn't be doing this right now but INVENTORY STUFF ####
# We should 100% have an InventoryController :\ It'll be largely for save state
# but also is used across both scenes. I don't love having it in EntityController
# What lives in the entity controller should be entities.
var ITEM_TO_RESOURCE = {
	"Bush": "TeaLeaf",
}

# TODO: Not in prototype scope, but I think gathered resources should be
# text on the side of the screen like RuneScape. Not using the dialogue windows.
func collect_resource(item_name):
	var resource = ITEM_TO_RESOURCE[item_name]
	print("Collected ", resource, "!")
