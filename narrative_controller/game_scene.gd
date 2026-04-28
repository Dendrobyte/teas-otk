extends Node3D
class_name GameScene

signal character_initialized
signal npc_initialized

func _enter_tree():
	add_to_group("game_scene")

func character_is_loaded(body: CharacterBody3D):
	character_initialized.emit(body)

# NOTE: May turn into load_entity that takes NPC base or entity base
# or just the one if I can successfully combine them
func npc_is_loaded(npc_base: NPCBase):
	npc_initialized.emit(npc_base)

func unload_scene():
	var scene_name = get_children().get(0) # GameScene should only ever have one child
	print("Unloading current scene: ", scene_name)
	scene_name.queue_free()

# TODO: I think we should await all signals complete in the child scene when it loads
# before we show anything. To be figured out 'next'
func load_scene(scene_path):
	print("Loading scene: ", scene_path)
	var scene = load(scene_path)
	var instance = scene.instantiate()
	add_child(instance)

	
