extends Node
class_name EntityController

var narrative_controller: NarrativeController
func initialize(narrative_controller_ref: NarrativeController):
	narrative_controller = narrative_controller_ref

	narrative_controller.game_scene.npc_initialized.connect(init_npc_base)

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
var CUSTOM_NPCS: Dictionary[String, NPCBase] = {
	"OldMan": null,
	"SadGuard": null,
	"CitadelGuard": null,
}

func get_custom_npc_refs():
	return CUSTOM_NPCS

func init_npc_base(npc: NPCBase):
	npc.npc_collision_enter.connect(_on_character_enters_entity_area)
	npc.npc_collision_leave.connect(_on_character_leaves_entity_area)
	# TODO: See bigger note above, but don't hard code these values p much
	if CUSTOM_NPCS.has(npc.name):
		CUSTOM_NPCS[npc.name] = npc

# TODO: Wire this up. May end up being one function in the next refactor
# func init_item_base(item: EntityBase)
# 	# The items are structured in groups for the scatter script
# 	# TODO: When refactoring NPCs/Entities, NPCBase and EntityBase might inherit from same thing?
# 	# 		I could see a world where EntityBase is parent of NPCBase and ItemBase
# 	for item_node_group in item_parent_node.get_children():
# 		for	item_node in item_node_group.get_children():
# 			var entity: EntityBase = item_node as EntityBase

# 			entity.entity_collision_enter.connect(_on_character_enters_entity_area)
# 			entity.entity_collision_leave.connect(_on_character_leaves_entity_area)

func get_entity_ref(node_name: String):
	return CUSTOM_NPCS[node_name]

var curr_npc_in_range_name: String
func get_nearest_entity_name():
	return curr_npc_in_range_name
# NOTE: Do we want to return a ref instead? Name oK for now

# When an NPC emits a collision signal on entry, we show the interact button
# TODO: If there already is an NPC held on to, we only save the closest one
#		For now, we just replace. Should become a list ordered by close-ness
# TODO: This triggers on init based on print statements. Does that become a problem?
func _on_character_enters_entity_area(body: Node3D):
	curr_npc_in_range_name = body.name
	narrative_controller.toggle_interact_button(true, body.global_position)

func _on_character_leaves_entity_area(_body: Node3D):
	# TODO: Bump the list down if there are more entities around
	#		Otherwise we're just clearing the entity from the list
	narrative_controller.toggle_interact_button(false)