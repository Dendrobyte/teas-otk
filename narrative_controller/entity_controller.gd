extends Node
class_name EntityController

# TODO
# We'll get to this next with the entity refactors
# For now, just scrap together what works with the most simplicity

# Some map of all NPCs whose behavior we need to tweak
# Or anything that might be referenced in an animation
# Should be hard written like the flags end up being
# Every key in here MUST match the node name of NPCs in the Godot Scene
# TODO: Remove the strings. It'll be "NodeName" -> ref
var CUSTOM_NPCS: Dictionary[String, NPCBase] = {
	"OldMan": null,
	"SadGuard": null,
	"CitadelGuard": null,
}


# NOTE
# Anything global and not per-entity should be handled in Narrative Controller?


# Iterates over the entity nodes from the GameScene passed in by NarrativeController
# npc_parent_node is the NPCs node
# item_parent_node is the Environment (grass, trees, etc.)
func init_load_entities(npc_parent_node, item_parent_node):
	for npc_node in npc_parent_node.get_children():
		var npc: NPCBase = npc_node as NPCBase

		npc.npc_collision_enter.connect(_on_character_enters_entity_area)
		npc.npc_collision_leave.connect(_on_character_leaves_entity_area)

	# The items are structured in groups for the scatter script
	# TODO: When refactoring NPCs/Entities, NPCBase and EntityBase might inherit from same thing?
	# 		I could see a world where EntityBase is parent of NPCBase and ItemBase
	for item_node_group in item_parent_node.get_children():
		for	item_node in item_node_group.get_children():
			var entity: EntityBase = item_node as EntityBase

			entity.entity_collision_enter.connect(_on_character_enters_entity_area)
			entity.entity_collision_leave.connect(_on_character_leaves_entity_area)

func get_entity_ref(node_name: String):
	return CUSTOM_NPCS[node_name]

# When an NPC emits a collision signal on entry, we show the interact button
# NOTE: Doubling up and doing all entities here
# NOTE: Seems like these signals don't have to do much but return some values
# we should determine in the narrative controller
func _on_character_enters_entity_area(body: Node3D):
	var npc_name = body.name
	Util.interact_button_show(body.global_position)
	can_interact = true
	curr_npc_in_range = npc_name
	return true # So that we know a character can interact with something

func _on_character_leaves_entity_area(_body: Node3D):
	Util.interact_button_hide()
	# TODO: If entity is npc... etc.
	# Use the false return in narrative controller?
	hide_dialogue()
	# TODO: Note that we should be holding on to everything they COULD interact with, it's just not this thing
	return false # So that we know a character can no longer interact with something